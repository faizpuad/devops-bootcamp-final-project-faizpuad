output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_sg_id" {
  value = module.public_sg.security_group_id
}

output "private_sg_id" {
  value = module.private_sg.security_group_id
}

output "web_server_eip" {
  value = module.web_server.public_ip
}

output "ansible_private_ip" {
  value = module.ansible_controller.private_ip
}

output "monitoring_private_ip" {
  value = module.monitoring_server.private_ip
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecr_repository_arn" {
  value = module.ecr.repository_arn
}
