terraform {
  # version tf
  required_version = ">=1.7, <2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = ">=5.0, <6.0"
      version = ">=6.0, <7.0" # (2026-04)
    }
  }
}