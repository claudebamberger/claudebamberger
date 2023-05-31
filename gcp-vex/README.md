# gcp gcloud commands & terraform

## gcloud

* install [gcloud tools](https://cloud.google.com/sdk/docs/install)
  ou via ``https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-432.0.0-darwin-x86_64.tar.gz``
* untar, copié dans ``~/.gcp/google-cloud-sdk``
* lancer ``./google-cloud-sdk/install.sh``
* qui va renseigner ``.zprofile`` et corriger manuellement
* penser à faire 
  ```
  > gcloud components install log-streaming minikube terraform-tools \
          config-connector app-engine-java \
          app-engine-php gke-gcloud-auth-plugin kubectl
  ```
* Créer le projet dans la console (PROJECT_ID -> nom-numéro)
* Dans le projet activer Compute Engine
* se connecter avec
  ```
  > gcloud auth login
  You are now logged in as [xxx@yyyy.zzz]
  > gcloud projects list
  ...
  > gcloud config set project [PROJECT_ID]
  ```

## Terraform
* télécharger [terraform](https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_darwin_arm64.zip) et installer dans ``/usr/local/bin/tf``
* prévoir un .gitignore plus haut (ou racine) avec
    ```
    .terraform/
    .terraform/**
    .terraform.*
    *.tfstate
    *.tfstate.*
    ```

* faire un ``main.tf`` dans un répertoire ``land`` pour vérifier
  ```
  terraform {
    required_providers {
      google = {
        source = "hashicorp/google"
        version = "~> 4.0"
      }
    }
  }

  provider "google" {
    project = "[PROJECT_ID]"
    region  = "[GCP_REGION]"
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
  ```
* on peut se connecter avec 

  ``gcloud compute ssh --zone "[retrouver la zone]" "wopr" --project "[PROJECT_ID]"``

* résultat
  ```
  mex@wopr:~$ neofetch 
        _,met$$$$$gg.          mex@wopr 
      ,g$$$$$$$$$$$$$$$P.       -------- 
    ,g$$P"     """Y$$.".        OS: Debian GNU/Linux 11 (bullseye) x86_64 
  ,$$P'              `$$$.     Host: Google Compute Engine 
  ',$$P       ,ggs.     `$$b:   Kernel: 5.10.0-22-cloud-amd64 
  `d$$'     ,$P"'   .    $$$    Uptime: 37 mins 
  $$P      d$'     ,    $$P    Packages: 381 (dpkg) 
  $$:      $$.   -    ,d$$'    Shell: bash 5.1.4 
  $$;      Y$b._   _,d$P'      Terminal: /dev/pts/3 
  Y$$.    `.`"Y$$$$P"'         CPU: Intel Xeon (2) @ 2.199GHz 
  `$$b      "-.__              Memory: 210MiB / 975MiB 
    `Y$$
    `Y$$.                                              
      `$$b.                                            
        `Y$$b.
            `"Y$b._
                `"""

  mex@wopr:~$ 
  ```