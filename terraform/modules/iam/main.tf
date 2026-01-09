variable "bucket_arn" {
  type = string
}

# Define the custom policy for the SSM S3 bucket
resource "aws_iam_policy" "ansible_ssm_s3_policy" {
  name        = "AnsibleSSMS3Access"
  description = "Allows access to the specific Ansible SSM transfer bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:DeleteObject"
        ]
        Resource = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      }
    ]
  })
}

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
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    aws_iam_policy.ansible_ssm_s3_policy.arn # Replaced S3ReadOnly with strict policy
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