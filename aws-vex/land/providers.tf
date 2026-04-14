### Terraform (tool) https://developer.hashicorp.com/terraform/install
# V1.7.2
terraform {
  # version tf
  required_version = ">=1.11, <2.0"
  # v1.14 (2026-04)
  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      # 5.34 -> 5.94 (2025-04)
      source  = "hashicorp/aws"
      # version = ">=5.94, <6.0"
      version = ">=6.0, <7.0" # (2026-04)
    }
    # aussi module vpc dans main.cf
    # source  = "terraform-aws-modules/vpc/aws"
    # version = ">=5.19,<6.0" (2025)
    # version = ">=6.0,<7.0" # 6.6.1 (2026-04)

  }
}
provider "aws" {
  region = var.AWS_REGION
}