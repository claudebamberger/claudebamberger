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
data "google_compute_zones" "available" {
}
resource "google_compute_network" "lander" {
  name                    = "lander"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "lander-subnetwork"
  ip_cidr_range = var.GCP_LANDER_CIDR_BLOCK
  region        = var.GCP_REGION
  network       = google_compute_network.lander-subnet.id
  // optional: secondary_ip_range { range_name = "…" ip_cidr_range = "…" }
}
resource "google_compute_network" "lander-subnet" {
  name                    = "lander-test-subnet"
  auto_create_subnetworks = false
}

resource "google_compute_instance" "wopr" {
  description  = "wopr"
  name         = "wopr"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config { // Ephemeral public IP
    }
  }
  zone = data.google_compute_zones.available.names[0]
}