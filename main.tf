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
