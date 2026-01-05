variable "aws_region" {
  type    = string
  default = "us-east-1"
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

variable "monitoring_server_ip" {
  description = "Monitoring server IP for Prometheus Node Exporter access"
  type        = string
}

variable "vpc_subnet_cidr" {
  description = "CIDR range of the VPC subnets"
  type        = string
  default     = "10.0.0.0/24"
}
