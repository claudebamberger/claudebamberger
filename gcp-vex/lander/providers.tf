terraform {
  required_version = ">=1.4, <2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.7, <6.0"
    }
  }
}
provider "google" {
  project = var.GCP_PROJECT_ID
  region  = var.GCP_REGION
  //zone    = ""
}