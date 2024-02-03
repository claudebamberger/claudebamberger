### Terraform (tool) https://developer.hashicorp.com/terraform/install
# V1.7.2
terraform {
  # version tf
  required_version = ">=1.7, <2.0"
  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      # 5.34
      source  = "hashicorp/aws"
      version = ">=5.0, <6.0"
    }
    # aussi module vpc
    # source  = "terraform-aws-modules/vpc/aws"
    # version = ">=5.0,<6.0"
  }
}
provider "aws" {
  region = var.AWS_REGION
}