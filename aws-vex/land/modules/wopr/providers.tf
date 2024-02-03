terraform {
  required_providers {
    required_version = ">=1.7, <2.0"
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0, <6.0"
    }
  }
}