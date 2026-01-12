variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.0.0/25"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.0.128/25"]
}

# variable "monitoring_server_ip" {
#   description = "Monitoring server IP for Prometheus Node Exporter access"
#   type        = string
# }

variable "vpc_subnet_cidr" {
  description = "CIDR range of the VPC subnets"
  type        = string
  default     = "10.0.0.0/24"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ubuntu_ami_name" {
  description = "Ubuntu 24.04 AMI name"
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
}

