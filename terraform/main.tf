data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get acc and region for ansible ssm s3 bucket naming
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  # Convention: ansible-ssm-transfer-<account-id>-<region>
  ssm_bucket_name = "ansible-ssm-transfer-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
}

# Create the S3 Bucket for Ansible SSM File Transfer
module "ansible_ssm_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket        = local.ssm_bucket_name
  force_destroy = true # Allows terraform destroy to remove bucket even if it has files

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = false
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "devops-vpc"
  cidr = var.vpc_cidr

  azs             = ["ap-southeast-1a"]
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Project = "devops-bootcamp"
  }

  public_subnet_tags = {
    Name = "devops-public-subnet"
  }

  private_subnet_tags = {
    Name = "devops-private-subnet"
  }

  igw_tags = {
    Name = "devops-igw"
  }

  nat_gateway_tags = {
    Name = "devops-ngw"
  }
}

# web server SG (public)
module "public_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "devops-public-sg"
  description = "Security group for public web servers"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS from anywhere (Required for Cloudflare Full SSL)"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      description = "Prometheus Node Exporter from Monitoring Server"
      cidr_blocks = "${module.monitoring_server.private_ip}/32"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from VPC only"
      cidr_blocks = var.vpc_subnet_cidr
    }
  ]

  egress_rules = ["all-all"]
}

# private SG (Ansible + Monitoring)
module "private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "devops-private-sg"
  description = "Security group for Ansible controller and monitoring servers"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH from VPC only"
      cidr_blocks = var.vpc_subnet_cidr
    }
  ]

  egress_rules = ["all-all"]
}

module "iam_roles" {
  bucket_arn = module.ansible_ssm_bucket.s3_bucket_arn
  source = "./modules/iam"
}

# ec2 web server
module "web_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "devops-web-server"

  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.public_subnets[0]
  private_ip             = "10.0.0.5"
  vpc_security_group_ids = [module.public_sg.security_group_id]

  associate_public_ip_address = true

  create_eip = true

  # enable ssm role
  iam_instance_profile = module.iam_roles.web_server_instance_profile_name

  tags = {
    Role = "web"
  }
}

# ec2 ansible controller
module "ansible_controller" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "devops-ansible-controller"

  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.private_subnets[0]
  private_ip             = "10.0.0.135"
  vpc_security_group_ids = [module.private_sg.security_group_id]

  associate_public_ip_address = false

  # enable ssm role
  iam_instance_profile = module.iam_roles.ansible_controller_instance_profile_name

  tags = {
    Role = "ansible"
  }
}

# ec2 monitoring server
module "monitoring_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name = "devops-monitoring-server"

  ami                    = data.aws_ami.ubuntu_2404.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.private_subnets[0]
  private_ip             = "10.0.0.136"
  vpc_security_group_ids = [module.private_sg.security_group_id]

  associate_public_ip_address = false

  # enable ssm role
  iam_instance_profile =module.iam_roles.monitoring_server_instance_profile_name

  tags = {
    Role = "monitoring"
  }
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  repository_name = var.ecr_repository_name
  repository_type = "private"

  repository_image_scan_on_push = true
  repository_force_delete       = true

  # make image mutable to allow overwriting tags like 'latest'
  repository_image_tag_mutability = "MUTABLE"
  
  create_lifecycle_policy = true

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Project = "devops-bootcamp"
  }
}

module "ssm" {
  source = "./modules/ssm"

  aws_region             = data.aws_region.current.name
  controller_instance_id = module.ansible_controller.id
  web_instance_id        = module.web_server.id
  monitoring_instance_id = module.monitoring_server.id
  # web_private_ip         = module.ec2.web_private_ip
  ecr_repository_url     = module.ecr.repository_url
}



