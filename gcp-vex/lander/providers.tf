### Terraform (tool) https://developer.hashicorp.com/terraform/install
# V1.7.2 -...-> 1.11.3 (2025-04)
terraform {
  # version tf
  required_version = ">=1.11, <2.0"
  required_providers {
    google = {
      # https://registry.terraform.io/providers/hashicorp/google/latest
      # 5.14 -> 6.28 (2025-04)
      source  = "hashicorp/google"
      version = ">=6.28, <7.0"
    }
    # aussi module vpc
    # source = "terraform-google-modules/network/google"
    # version = "~> 9.0" -> 9.3 (2025-04, even 10.0 exists)
  }
}
provider "google" {
  project = var.GCP_PROJECT_ID
  region  = var.GCP_REGION
  //zone    = ""
}