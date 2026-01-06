output "web_server_instance_profile_name" {
  value = module.web_server_role.iam_instance_profile_name
}

output "ansible_controller_instance_profile_name" {
  value = module.ansible_controller_role.iam_instance_profile_name
}

output "monitoring_server_instance_profile_name" {
  value = module.monitoring_server_role.iam_instance_profile_name
}