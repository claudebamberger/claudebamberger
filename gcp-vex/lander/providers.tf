### Terraform (tool) https://developer.hashicorp.com/terraform/install
# V1.7.2
terraform {
  # version tf
  required_version = ">=1.7, <2.0"
  required_providers {
    google = {
      # https://registry.terraform.io/providers/hashicorp/google/latest
      # 5.14
      source  = "hashicorp/google"
      version = ">=5.0, <6.0"
    }
    # aussi module vpc
    # source = "terraform-google-modules/network/google"
    # version = "~> 9.0"
  }
}
provider "google" {
  project = var.GCP_PROJECT_ID
  region  = var.GCP_REGION
  //zone    = ""
}