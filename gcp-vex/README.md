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
* télécharger [terraform](https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_darwin_arm64.zip) et installer dans ``/usr/local/bin/tf`` (avec un lien /usr/local/terraform/…)
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
## Terraform docs
* télécharger [terraform-docs](https://github.com/terraform-docs/terraform-docs/releases/download/v0.17.0/terraform-docs-v0.17.0-darwin-arm64.tar.gz) et installer dans ``/usr/local/bin/tf-docs`` (avec un lien /usr/local/terraform/…)
* faire 
    ```
    tf-docs markdown .
    ```

### Documentation des ressources dans l'exemple
```mermaid
    graph LR
    main.tf --> variables.tf
    variables.tf --o ProjectID>GCP_PROJECT_ID]
    variables.tf --o Region>GCP_REGION]
    variables.tf --o SecureCIDR>GCP_SECURE_CIDR]
    variables.tf --o PublicCIDR>GCP_LANDER_SUBNET_PUBLIC]
    variables.tf --o PrivateCIDR>GCP_LANDER_SUBNET_PRIVATE]
    main.tf -.-> wopr_data
    wopr_data(google_compute_disk.wopr_data)
    main.tf -.-> lander
    lander(google_compute_network.lander)
    admin-public-ip
    admin-public-ip(google_compute_address.admin-public-ip)
    main.tf -.-> lander-subnet-public
    lander-subnet-public
    lander-subnet-public(google_compute_subnetwork.lander-subnet-public)
    lander-subnet-public -.-> PublicCIDR
    lander-subnet-public -.-> Region
    lander-subnet-public -.-> lander
    main.tf -.-> lander-subnet-private
    lander-subnet-private(google_compute_subnetwork.lander-subnet-private)
    lander-subnet-private -.-> PrivateCIDR
    lander-subnet-private -.-> lander
    lander-subnet-private -.-> Region
    main.tf -.-> landline
    landline(google_compute_firewall.landline)
    landline -.-> lander
    landline -.-> PublicCIDR
    landline -.-> SecureCIDR
    landline -.-> ssh>ssh tcp/22]
    landline ---> #ssh-admin
    main.tf -.-> landlineInt
    landlineInt>google_compute_firewall.landlineInternal]
    landlineInt -.-> lander
    landlineInt -.-> PrivateCIDR
    landlineInt -.-> PublicCIDR
    landlineInt -.-> ssh>ssh tcp/22]
    landlineInt ---> #ssh-internal
    main.tf -.-> woprPub
    woprPub>google_compute_instance.woprPub]
    woprPub -.-> lander-subnet-public
    woprPub -.-> admin-public-ip
    woprPub -.-> #ssh-admin
    woprPub -.-> #ssh-internal
    woprPub --> setup(remote-exec update-upgrade)
    main.tf -.-> woprPriv
    woprPriv>google_compute_instance.woprPriv]
    woprPriv -.-> lander-subnet-private
    woprPriv --> init(remote-exec mark)
    
    woprPriv -.-> #ssh-internal
    woprPriv -.-> att-wopr-data[google_compute_attached_disk.wopr-data]
    att-wopr-data --> mount(remote-exec mount)
    att-wopr-data -.-> wopr_data
  ```

  ### Auto-documentation
  // generated with tf-docs -c .terraform-docs.yml . //
  [//]: # (BEGIN_TF_DOCS)
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.7, <2.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=5.0, <6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.13.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 9.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.admin_public_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.landline-external-e](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.landline-external-i](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.landline-internal-e](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.landline-internal-i](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.no-other-egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.no-other-ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.proxyland-internal-e](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.proxyland-internal-i](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.woprPriv](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance.woprPub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_subnetwork.lander_priv](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_compute_subnetwork.lander_pub](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_dns_record_set.WoprPubDNS](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_compute_disk.wopr_data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_disk) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_dns_managed_zone.env_dns_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/dns_managed_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_GCP_LANDER_CIDR_BLOCK"></a> [GCP\_LANDER\_CIDR\_BLOCK](#input\_GCP\_LANDER\_CIDR\_BLOCK) | CIDR correspondant au réseau | `string` | `"192.168.88.0/24"` | no |
| <a name="input_GCP_LANDER_SUBNET_PRIVATE"></a> [GCP\_LANDER\_SUBNET\_PRIVATE](#input\_GCP\_LANDER\_SUBNET\_PRIVATE) | CIDR correspondant au sous-réseau privé | `string` | `"192.168.88.0/28"` | no |
| <a name="input_GCP_LANDER_SUBNET_PUBLIC"></a> [GCP\_LANDER\_SUBNET\_PUBLIC](#input\_GCP\_LANDER\_SUBNET\_PUBLIC) | CIDR correspondant au sous-réseau public | `string` | `"192.168.88.16/28"` | no |
| <a name="input_GCP_PRIVATE_KEY_PATH"></a> [GCP\_PRIVATE\_KEY\_PATH](#input\_GCP\_PRIVATE\_KEY\_PATH) | chemin de la clé privée (pour la région), exported shell | `string` | n/a | yes |
| <a name="input_GCP_PROJECT_ID"></a> [GCP\_PROJECT\_ID](#input\_GCP\_PROJECT\_ID) | Projet GCP visé, exported shell | `string` | n/a | yes |
| <a name="input_GCP_PUBLIC_KEY_PATH"></a> [GCP\_PUBLIC\_KEY\_PATH](#input\_GCP\_PUBLIC\_KEY\_PATH) | chemin de la clé publique (pour la région), exported shell | `string` | n/a | yes |
| <a name="input_GCP_REGION"></a> [GCP\_REGION](#input\_GCP\_REGION) | région GCP visée, exported shell | `string` | n/a | yes |
| <a name="input_GCP_SECURE_CIDR"></a> [GCP\_SECURE\_CIDR](#input\_GCP\_SECURE\_CIDR) | CIDR sûr en entrée, exported shell | `string` | n/a | yes |
| <a name="input_GCP_ZONE_DNS"></a> [GCP\_ZONE\_DNS](#input\_GCP\_ZONE\_DNS) | nom de la zone DNS déclarée, exported shell | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_publicAdminIp"></a> [publicAdminIp](#output\_publicAdminIp) | ######### ## Output ######### |

[//]: # (END_TF_DOCS)