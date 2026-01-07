variable "controller_instance_id" {
  description = "EC2 instance ID of Ansible Controller"
  type        = string
}

variable "web_instance_id" {
  description = "EC2 instance ID of Web Server"
  type        = string
}

variable "monitoring_instance_id" {
  description = "EC2 instance ID of Monitoring Server"
  type        = string
}

# # Might not use since using insatnce ID for SSM connection
# variable "web_private_ip" {
#   description = "Private IP of Web Server"
#   type        = string
# }

variable "ecr_repository_url" {
  description = "ECR repository URI for web application"
  type        = string
}
