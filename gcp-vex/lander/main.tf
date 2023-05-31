terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
provider "google" {
  project = var.GCP_PROJECT_ID
  region  = var.GCP_REGION
  //zone    = ""
}
resource "google_compute_network" "lander" {
  name                    = "lander"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "lander-subnetwork"
  ip_cidr_range = var.GCP_LANDER_CIDR_BLOCK
  region        = var.GCP_REGION
  network       = google_compute_network.lander-test.id
  // optional secondary_ip_range { range_name = "…" ip_cidr_range = "…" }
}
resource "google_compute_network" "lander-test" {
  name                    = "lander-test-subnet"
  auto_create_subnetworks = false
}

# SEE https://registry.terraform.io/modules/terraform-google-modules/network/google/latest/submodules/subnets