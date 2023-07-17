terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.16, <6.0"
    }
  }
  required_version = ">= 1.2.0, <2.0"
}