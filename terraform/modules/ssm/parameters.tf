resource "aws_ssm_parameter" "aws_region" {
  name  = "/devops/aws-region"
  type  = "String"
  value = var.aws_region

  tags = {
    Project = "devops-bootcamp"
  }
}

resource "aws_ssm_parameter" "controller_instance_id" {
  name  = "/devops/controller/instance-id"
  type  = "String"
  value = var.controller_instance_id

  tags = {
    Project = "devops-bootcamp"
  }
}

resource "aws_ssm_parameter" "web_instance_id" {
  name  = "/devops/web/instance-id"
  type  = "String"
  value = var.web_instance_id

  tags = {
    Project = "devops-bootcamp"
  }
}

resource "aws_ssm_parameter" "monitoring_instance_id" {
  name  = "/devops/monitoring/instance-id"
  type  = "String"
  value = var.monitoring_instance_id

  tags = {
    Project = "devops-bootcamp"
  }
}

# # Might not use since using insatnce ID for SSM connection
# resource "aws_ssm_parameter" "web_private_ip" {
#   name  = "/devops/web/private-ip"
#   type  = "String"
#   value = var.web_private_ip

#   tags = {
#     Project = "devops-bootcamp"
#   }
# }

resource "aws_ssm_parameter" "ecr_repository_url" {
  name  = "/devops/ecr/webapp-repo-uri"
  type  = "String"
  value = var.ecr_repository_url

  tags = {
    Project = "devops-bootcamp"
  }
}
