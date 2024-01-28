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
      direction   = "INGRESS"
      # https://www.middlewareinventory.com/blog/create-linux-vm-in-gcp-with-terraform-remote-exec/#compute_firewall_block_-_Allow_SSH_and_HTTPS_connections
      allow = [{
        ports    = ["22"]
        protocol = "tcp"
      }]
      target_tags = ["ssh-admin"]
      # source_ranges nécessaire car pas de source_tags (un des 2 obligatoire)
      source_ranges = ["${var.GCP_SECURE_CIDR}"]
    },
    {
      name        = "landline-internal"
      description = "firewall for ssh access"
      direction   = "INGRESS"
      allow = [{
        ports    = ["22"]
        protocol = "tcp"
        },
        {
          protocol = "icmp"
      }]
      target_tags = ["ssh-internal"]
      source_tags = ["ssh-internal"]
      # pas forcément utile avec les tags, instable en plan: source_ranges = ["${var.GCP_LANDER_SUBNET_PRIVATE}", "${var.GCP_LANDER_SUBNET_PUBLIC}"]
    },
    {
      name        = "proxyland-internal"
      description = "firewall for proxy access"
      direction   = "INGRESS"
      allow = [{
        ports    = ["8888"]
        protocol = "tcp"
      }]
      target_tags = ["wopr-pub"]
      source_tags = ["wopr-priv"]
      # pas forcément utile avec les tags, instable en plan: source_ranges = ["${var.GCP_LANDER_SUBNET_PRIVATE}"]
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
### WoprPub
resource "google_compute_instance" "woprPub" {
  description  = "wopr-pub"
  name         = "wopr-pub"
  tags         = ["ssh-admin", "ssh-internal", "wopr-pub"] # utilisé par le firewall
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
      agent       = true
      private_key = file(var.GCP_PRIVATE_KEY_PATH)
      timeout     = "60s" # semble nécessaire >30s
    }
    inline = [
      "ssh-agent && ssh-add -L",
      "sudo bash -c 'export DEBIAN_FRONTEND=noninteractive && apt -yq update && apt -yq upgrade'",
      "sudo bash -c 'export DEBIAN_FRONTEND=noninteractive && apt -yq install cowsay zip unzip net-tools inetutils-ping dnsutils vim ufw cron ansible neofetch'",
      "sudo apt -yq install tinyproxy",
      "sudo sh -c 'cat /etc/tinyproxy/tinyproxy.conf | sed \"s/\\#Allow 192\\.168\\.0\\.0\\/16/Allow ${google_compute_instance.woprPriv.network_interface[0].network_ip}/g\" > /etc/tinyproxy/tinyproxy.conf.tmp'",
      "sudo sh -c 'cat /etc/tinyproxy/tinyproxy.conf.tmp | sed \"s/\\#Allow 10\\.0\\.0\\.0\\/8/#Allow 10.0.0.0\\/8/g\" > /etc/tinyproxy/tinyproxy.conf'",
      "sudo rm /etc/tinyproxy/tinyproxy.conf.tmp",
      "sudo chown tinyproxy:tinyproxy /var/log/tinyproxy",
      "sudo systemctl restart tinyproxy",
      "sudo echo $(date) > /tmp/provisioner",
    ]
  }
}

### WoprPriv

resource "google_compute_instance" "woprPriv" {
  description  = "wopr-priv"
  name         = "wopr-priv"
  tags         = ["ssh-internal", "wopr-priv"] # utilisé par le firewall
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
  # TODO: risque de ne pas marcher
  # TODO: verifier le bon acces via proxy
  # "sudo echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-ansible",
  # "sudo chown -R ansible:operator /wopr4/ansible",
  provisioner "remote-exec" {
    connection {
      # user is added to sudoers (good)
      bastion_host        = google_compute_address.admin_public_ip.address
      bastion_user        = "ansible"
      bastion_private_key = file(var.GCP_PRIVATE_KEY_PATH)
      host                = google_compute_instance.woprPriv.network_interface[0].network_ip
      user                = "ansible"
      type                = "ssh"
      agent               = true
      private_key         = file(var.GCP_PRIVATE_KEY_PATH)
      timeout             = "60s"
    }
    inline = [
      "sudo echo $(date)> /tmp/provisioner",
      "sudo sh -c 'echo Acquire::http::proxy http://wopr-pub/:8888/; > /etc/apt/apt.conf.d/60tinyproxy.conf'",
      "timeout 300 sh -c 'export http_proxy=http://wopr-pub:8888; curl aws.com; while [ $? != 0 ]; do sleep 30; curl aws.com; done '",
      "sudo apt-get update && sudo apt-get full-upgrade -y",
      "sudo apt-get install -y git cowsay zip unzip net-tools inetutils-ping dnsutils vim ufw cron ansible ansible-lint neofetch ",
      "sudo sh -c 'echo export http_proxy=http://wopr-pub:8888 >> /etc/profile'",
      "sudo mount /dev/sdb /wopr4",
      "sudo grep 'wopr4' /etc/fstab; if [ $? != 0 ]; then sudo echo $(blkid /dev/sdb|grep 'LABEL=.wopr-data'|col3) /wopr4 ext4 defaults,nofail 0 1 > /tmp/prepfstab; sudo sh -c 'cat /tmp/prepfstab >> /etc/fstab' ; fi",
      "sudo mount -a",
      "sudo sh -c 'if [ ! -L /root/data ]; then ln -s /wopr4/root /root/data; fi'",
      "sudo sh -c 'if [ ! -L /home/ubuntu/data ]; then ln -s /wopr4/ubuntu /home/ubuntu/data; fi'",
      "sudo sh -c 'if [ ! -L /home/ansible/data ]; then ln -s /wopr4/ansible /home/ansible/data; fi'",
    ]
  }
  attached_disk {
    # est monté en /dev/sdb
    mode        = "READ_WRITE"
    device_name = "wopr-data-0"
    source      = data.google_compute_disk.wopr_data.id
  }
}
##########
### DNS registration
##########
resource "google_dns_record_set" "WoprPubDNS" {
  name         = "wopr.${data.google_dns_managed_zone.env_dns_zone.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  rrdatas      = ["${google_compute_address.admin_public_ip.address}"]
}
##########
### Output
##########
output "publicAdminIp" {
  value = "ssh-agent && ssh-add […] ssh -A ansible@wopr.gcp.claudebbg.com"
}