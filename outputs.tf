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
