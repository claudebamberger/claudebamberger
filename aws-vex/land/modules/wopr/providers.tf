terraform {
  # version tf
  required_version = ">=1.7, <2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0, <6.0"
    }
  }
}