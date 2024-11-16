### Landline-external
# secure-cidr -> ssh-admin(wopr-pub):22
# ssh-admin -> 0.0.0.0/0:[80,443]

resource "google_compute_firewall" "landline-external-i" {
  network     = module.vpc.network_id
  name        = "landline-external-i"
  description = "firewall for ssh access"
  direction   = "INGRESS"
  # https://www.middlewareinventory.com/blog/create-linux-vm-in-gcp-with-terraform-remote-exec/#compute_firewall_block_-_Allow_SSH_and_HTTPS_connections
  priority = 1000
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  target_tags = ["ssh-admin"]
  # source_ranges nécessaire car pas de source_tags (un des 2 obligatoire)
  source_ranges = ["${var.GCP_SECURE_CIDR}"]
}
resource "google_compute_firewall" "landline-external-e" {
  network     = module.vpc.network_id
  name        = "landline-external-e"
  description = "firewall for ssh access"
  direction   = "EGRESS"
  priority    = 1000
  allow {
    ports    = ["80", "443"]
    protocol = "tcp"
  }
  destination_ranges = ["0.0.0.0/0"]
  source_ranges      = ["${var.GCP_LANDER_SUBNET_PUBLIC}"]
}

### Landline-internal
# ssh-internal (wopr-pub & priv) <-> ssh-internal (wopr-pub & priv):22
# ssh-internal (wopr-pub & priv) <-> ssh-internal (wopr-pub & priv) ICMP

resource "google_compute_firewall" "landline-internal-i" {
  network     = module.vpc.network_id
  name        = "landline-internal-i"
  description = "firewall for internal ssh access"
  direction   = "INGRESS"
  priority    = 1000
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  allow {
    protocol = "icmp"
  }
  target_tags = ["ssh-internal"]
  source_tags = ["ssh-internal"]
  # pas forcément utile avec les tags, instable en plan: source_ranges = ["${var.GCP_LANDER_SUBNET_PRIVATE}", "${var.GCP_LANDER_SUBNET_PUBLIC}"]
}

resource "google_compute_firewall" "landline-internal-e" {
  network = module.vpc.network_id

  name        = "landline-internal-e"
  description = "firewall for ssh internal access"
  direction   = "EGRESS"
  priority    = 1000
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  allow {
    protocol = "icmp"
  }
  target_tags   = ["ssh-internal"]
  source_ranges = ["${var.GCP_LANDER_SUBNET_PUBLIC}", "${var.GCP_LANDER_SUBNET_PRIVATE}"]
}

### Proxyland-internal
# wopr-priv -> wopr-pub:8888
# wopr-pub:8888 -> wopr-priv

resource "google_compute_firewall" "proxyland-internal-i" {
  network     = module.vpc.network_id
  name        = "proxyland-internal-i"
  description = "firewall for proxy access"
  direction   = "INGRESS"
  priority    = 1000
  allow {
    ports    = ["8888"]
    protocol = "tcp"
  }
  target_tags   = ["wopr-pub"]
  source_tags   = ["wopr-priv"]
  source_ranges = ["${var.GCP_LANDER_SUBNET_PRIVATE}"]
}

resource "google_compute_firewall" "proxyland-internal-e" {
  network     = module.vpc.network_id
  name        = "proxyland-internal-e"
  description = "firewall for proxy access"
  direction   = "EGRESS"
  priority    = 1000
  allow {
    ports    = ["8888"]
    protocol = "tcp"
  }
  # pas simple mais l'inverse coupe la communication
  destination_ranges = ["${var.GCP_LANDER_SUBNET_PUBLIC}"]
  source_ranges      = ["${var.GCP_LANDER_SUBNET_PRIVATE}"]
}

### NO other INGRESS/EGRESS
resource "google_compute_firewall" "no-other-ingress" {
  network     = module.vpc.network_id
  name        = "no-other-ingress"
  description = "no other ingress"
  direction   = "INGRESS"
  priority    = 65000
  deny {
    protocol = "tcp"
  }
  deny {
    protocol = "udp"
  }
  deny {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "no-other-egress" {
  network = module.vpc.network_id

  name        = "no-other-egress"
  description = "no other egress"
  direction   = "EGRESS"
  priority    = 65000
  deny {
    protocol = "tcp"
  }
  deny {
    protocol = "udp"
  }
  deny {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}