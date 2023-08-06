### penser à se connecter à gcloud (il donne l'url)
### penser à avoir créé un projet avec le bon id (cf. variable env)
### penser à avoir activé les APIs ComputeEngine et les APIs DNS
### penser à avoir créé un disque appelé wopr-data dans la première zone disponible de la région
##########
### DATAs
##########
data "google_compute_disk" "wopr_data" {
  name    = "wopr-data"
  project = var.GCP_PROJECT_ID
  zone    = data.google_compute_zones.available.names[0]
}
data "google_compute_zones" "available" {
  #https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones
}
data "google_dns_managed_zone" "env_dns_zone" {
  name = var.GCP_ZONE_DNS
}
##########
### network
##########
# DONE: module https://registry.terraform.io/modules/terraform-google-modules/network/google/latest
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 7.2"

  project_id   = var.GCP_PROJECT_ID
  network_name = "wopr-vpc"
  routing_mode = "GLOBAL"
  subnets = [
    {
      subnet_name   = "lander-public"
      subnet_ip     = "${var.GCP_LANDER_SUBNET_PUBLIC}"
      subnet_region = "${var.GCP_REGION}"
    },
    {
      subnet_name   = "lander-private"
      subnet_ip     = "${var.GCP_LANDER_SUBNET_PRIVATE}"
      subnet_region = "${var.GCP_REGION}"
    }
  ]
  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
  firewall_rules = [
    {
      name        = "landline-external"
      description = "firewall for ssh access"
      # https://www.middlewareinventory.com/blog/create-linux-vm-in-gcp-with-terraform-remote-exec/#compute_firewall_block_-_Allow_SSH_and_HTTPS_connections
        allow = [{
        ports    = ["22"]
        protocol = "tcp"
      }]
      source_ranges      = ["${var.GCP_SECURE_CIDR}"]
      destination_ranges = ["${var.GCP_LANDER_SUBNET_PUBLIC}"]
      direction          = "INGRESS"
      target_tags        = ["ssh-admin"]
    },
    {
      name        = "landline-internal"
      description = "firewall for ssh access"
      allow = [{
        ports    = ["22"]
        protocol = "tcp"
      }]
      direction = "INGRESS"
      source_ranges = [
        "${var.GCP_LANDER_SUBNET_PUBLIC}",
        "${var.GCP_LANDER_SUBNET_PRIVATE}"
      ]
      destination_ranges = [
        "${var.GCP_LANDER_SUBNET_PUBLIC}",
        "${var.GCP_LANDER_SUBNET_PRIVATE}"
      ]
      target_tags = ["ssh-internal"]
    }
  ]
}
resource "google_compute_address" "admin_public_ip" {
  name       = "admin-public-ip"
  project    = var.GCP_PROJECT_ID
  region     = var.GCP_REGION
  depends_on = [module.vpc]
}

##########
### instances
##########
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
    //subnetwork = google_compute_subnetwork.lander-public.id
    subnetwork = module.vpc.subnets_ids[0]
    access_config {
      nat_ip = google_compute_address.admin_public_ip.address
    }
  }
  metadata = {
    # NB: it's either oslogin OR ssh
    enable-oslogin = false
    ssh-keys       = "ansible:${file(var.GCP_PUBLIC_KEY_PATH)}\nmex:${file(var.GCP_PUBLIC_KEY_PATH)}"
  }
  provisioner "remote-exec" {
    # TODO: risque de ne pas marcher
    connection {
      # user is added to sudoers (good)
      host        = google_compute_address.admin_public_ip.address
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
  tags = ["ssh-admin", "ssh-internal"]
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
    //subnetwork = google_compute_subnetwork.lander-private.id
    subnetwork = module.vpc.subnets_ids[1]
  }
  metadata = {
    enable-oslogin = false
    ssh-keys       = "ansible:${file(var.GCP_PUBLIC_KEY_PATH)}\nmex:${file(var.GCP_PUBLIC_KEY_PATH)}"
  }
  provisioner "remote-exec" {
    connection {
      # user is added to sudoers (good)
      host        = google_compute_address.admin_public_ip.address
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
  tags = ["ssh-internal"]
}
### DNS registration
resource "google_dns_record_set" "WoprPubDNS" {
  name         = "wopr.${data.google_dns_managed_zone.env_dns_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  rrdatas      = ["${google_compute_address.admin_public_ip.address}"]
}
### Output
output "publicAdminIp" {
  value = "ssh-agent && ssh-add […] ssh -A ansible@wopr.gcp.claudebbg.com"
}