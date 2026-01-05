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


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "devops-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-east-1a"]
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

  tags = {
    Role = "monitoring"
  }
}

