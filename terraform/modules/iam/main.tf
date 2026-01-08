module "web_server_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role = true
  create_instance_profile = true
  role_name   = "web-server-role"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  # Remove MFA requirement for EC2
  role_requires_mfa = false

  tags = {
    Project = "devops-bootcamp"
  }
}

module "ansible_controller_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role = true
  create_instance_profile = true
  role_name   = "ansible-controller-role"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  ]

  # Remove MFA requirement for EC2
  role_requires_mfa = false

  tags = {
    Project = "devops-bootcamp"
  }
}

module "monitoring_server_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  create_role = true
  create_instance_profile = true
  role_name   = "monitoring-server-role"

  trusted_role_services = [
    "ec2.amazonaws.com"
  ]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  # Remove MFA requirement for EC2
  role_requires_mfa = false

  tags = {
    Project = "devops-bootcamp"
  }
}