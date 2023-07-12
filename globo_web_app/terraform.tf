terraform {
  required_version = ">=1.4, <2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0, <6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.5, <4.0"
    }
  }
}