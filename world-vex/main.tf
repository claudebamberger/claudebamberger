terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.42.0"
    }
    ovh = {
      source = "ovh/ovh"
      version = "~>0.31"
    }
  }
  required_version = ">= 1.2.0"
}
provider "google" {
  project = var.GCP_PROJECT_ID
  region  = var.GCP_REGION
  //zone    = ""
}
provider "aws" {
  region = var.AWS_REGION
}
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3/" # Authentication URL
  domain_name = "default" # Domain name - Always at 'default' for OVHcloud
  alias       = "ovh"
  #TODO https://help.ovhcloud.com/csm/en-public-cloud-compute-openstack-users?id=kb_article_view&sysparm_article=KB0050625
  #TODO https://help.ovhcloud.com/csm/en-public-cloud-compute-set-openstack-environment-variables?id=kb_article_view&sysparm_article=KB0050920#step-1-retrieve-the-variables
  #TODO https://help.ovhcloud.com/csm/en-public-cloud-compute-terraform?id=kb_article_view&sysparm_article=KB0050797
}
provider "ovh" {
  alias              = "ovh"
  endpoint           = "ovh-eu"
  application_key    = var.OVH_KEY
  application_secret = var.OVH_SECRET
  consumer_key       = var.OVH_CONSUMER_KEY
}
