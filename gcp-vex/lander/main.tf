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
data "google_compute_disk" "wopr_data" {
  name    = "wopr-data"
  project = var.GCP_PROJECT_ID
  zone    = data.google_compute_zones.available.names[0]
}
data "google_compute_zones" "available" {
  #https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones
}
resource "google_compute_network" "lander" {
  name                    = "lander"
  auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "lander-subnet-public" {
  name          = "lander-subnetwork-public"
  ip_cidr_range = var.GCP_LANDER_SUBNET_PUBLIC
  region        = var.GCP_REGION
  network       = google_compute_network.lander.id
  secondary_ip_range {
    range_name    = "lander-self-public"
    ip_cidr_range = "172.16.8.16/28"
  }
}
resource "google_compute_subnetwork" "lander-subnet-private" {
  name          = "lander-subnetwork-private"
  ip_cidr_range = var.GCP_LANDER_SUBNET_PRIVATE
  region        = var.GCP_REGION
  network       = google_compute_network.lander.id
  secondary_ip_range {
    range_name    = "lander-self-private"
    ip_cidr_range = "172.16.8.0/28"
  }
}
resource "google_compute_instance" "woprPub" {
  description  = "wopr-pub"
  name         = "wopr-pub"
  zone         = data.google_compute_zones.available.names[0]
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      #image = "debian-cloud/debian-11"
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      #https://gmusumeci.medium.com/how-to-deploy-an-ubuntu-linux-vm-instance-in-gcp-using-terraform-b94d0ed3a3a4
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.lander-subnet-public.id
    access_config { /* Ephemeral public IP */ }
  }
}
resource "google_compute_instance" "woprPriv" {
  description  = "wopr-priv"
  name         = "wopr-priv"
  zone         = data.google_compute_zones.available.names[0]
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.lander-subnet-private.id
  }
}
resource "google_compute_attached_disk" "wopr_data" {
  count    = (data.google_compute_disk.wopr_data.id == null) ? 0 : 1
  disk     = data.google_compute_disk.wopr_data.id
  instance = google_compute_instance.woprPriv.id
}