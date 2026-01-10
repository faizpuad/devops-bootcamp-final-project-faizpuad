terraform {
  backend "s3" {
    key = "terraform.tfstate"
    # bucket and region provided via -backend-config flags
  }
}
