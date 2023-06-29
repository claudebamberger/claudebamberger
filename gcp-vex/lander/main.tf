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

### DATAs
data "google_compute_disk" "wopr_data" {
  name    = "wopr-data"
  project = var.GCP_PROJECT_ID
  zone    = data.google_compute_zones.available.names[0]
}
data "google_compute_zones" "available" {
  #https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones
}
data "google_dns_managed_zone" "env_dns_zone" {
  name = "gcp-claudebbg-zone"
}
### network
# TODO: module https://registry.terraform.io/modules/terraform-google-modules/network/google/latest
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
resource "google_compute_address" "admin-public-ip" {
  name       = "admin-public-ip"
  project    = var.GCP_PROJECT_ID
  region     = var.GCP_REGION
  depends_on = [google_compute_firewall.landline]
}
resource "google_compute_firewall" "landline" {
  # https://www.middlewareinventory.com/blog/create-linux-vm-in-gcp-with-terraform-remote-exec/#compute_firewall_block_-_Allow_SSH_and_HTTPS_connections
  name        = "landline"
  description = "firewall for ssh access"
  network     = google_compute_network.lander.name
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  destination_ranges = ["${var.GCP_LANDER_SUBNET_PUBLIC}"]

  direction = "INGRESS"
  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  source_ranges = ["${var.GCP_SECURE_CIDR}"]
  target_tags   = ["ssh-admin"]
}
resource "google_compute_firewall" "landlineInternal" {
  name        = "landline-internal"
  description = "firewall for ssh access"
  network     = google_compute_network.lander.name
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction = "INGRESS"
  source_ranges = [
    "${var.GCP_LANDER_SUBNET_PUBLIC}",
    "${var.GCP_LANDER_SUBNET_PRIVATE}"
  ]
  log_config {
    metadata = "INCLUDE_ALL_METADATA"

  }
  target_tags = ["ssh-internal"]
}
### instances
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
    access_config {
      nat_ip = google_compute_address.admin-public-ip.address
    }
  }
  metadata = {
    # NB: it's either oslogin OR ssh
    enable-oslogin = false
    ssh-keys       = "ansible:${file(var.GCP_PUBLIC_KEY_PATH)}\nmex:${file(var.GCP_PUBLIC_KEY_PATH)}"
  }
  provisioner "remote-exec" {
    connection {
      # user is added to sudoers (good)
      host        = google_compute_address.admin-public-ip.address
      user        = "ansible"
      private_key = file(var.GCP_PRIVATE_KEY_PATH)
      timeout     = "30s"
    }
    inline = [
      "sudo bash -c 'export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get -yq upgrade'",
      "sudo bash -c 'export DEBIAN_FRONTEND=noninteractive && apt-get -yq install neofetch'",
      "sudo echo $(date)> /tmp/provisioner",
    ]
  }
  tags       = ["ssh-admin", "ssh-internal"]
  depends_on = [google_compute_firewall.landline, google_compute_firewall.landlineInternal]
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
  metadata = {
    enable-oslogin = false
    ssh-keys       = "ansible:${file(var.GCP_PUBLIC_KEY_PATH)}\nmex:${file(var.GCP_PUBLIC_KEY_PATH)}"
  }
  provisioner "remote-exec" {
    connection {
      # user is added to sudoers (good)
      host        = google_compute_address.admin-public-ip.address
      user        = "ansible"
      private_key = file(var.GCP_PRIVATE_KEY_PATH)
      timeout     = "30s"
    }
    inline = [
      # pas possible d'accéder à internet depuis priv
      "sudo echo $(date)> /tmp/provisioner",
    ]
  }
  attached_disk {
    mode        = "READ_WRITE"
    device_name = "wopr-data-0"
    source      = data.google_compute_disk.wopr_data.id

  }
  tags       = ["ssh-internal"]
  depends_on = [google_compute_firewall.landlineInternal]
}
### DNS registration
resource "google_dns_record_set" "dns" {
  name         = "wopr.${data.google_dns_managed_zone.env_dns_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  rrdatas      = ["${google_compute_address.admin-public-ip.address}"]
}
### Output
output "publicAdminIp" {
  value = "ssh-agent && ssh-add […] ssh -A ansible@wopr.gcp.claudebbg.com"
}