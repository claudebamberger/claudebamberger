##################################################################################
# CONFIGURATION - added for Terraform 0.14
##################################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~>2.0"
    }
  }
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  profile = "deep-dive"
  region  = var.region
}

provider "consul" {
  address    = "${var.consul_address}:${var.consul_port}"
  datacenter = var.consul_datacenter
}

##################################################################################
# DATA
##################################################################################

data "aws_availability_zones" "available" {}

data "consul_keys" "networking" {
  key {
    name = "networking"
    path = terraform.workspace == "default" ? "networking/configuration/globo-primary/net_info" : "networking/configuration/globo-primary/${terraform.workspace}/net_info"
  }

  key {
    name = "common_tags"
    path = "networking/configuration/globo-primary/common_tags"
  }
}

##################################################################################
# LOCALS
##################################################################################

locals {
  cidr_block   = jsondecode(data.consul_keys.networking.var.networking)["cidr_block"]
  subnet_count = jsondecode(data.consul_keys.networking.var.networking)["subnet_count"]
  common_tags = merge(jsondecode(data.consul_keys.networking.var.common_tags),
    {
      Environment = terraform.workspace
    }
  )
}

##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>2.0"

  name = "globo-primary-${terraform.workspace}"

  cidr            = local.cidr_block
  azs             = slice(data.aws_availability_zones.available.names, 0, local.subnet_count)
  #private_subnets = data.template_file.private_cidrsubnet.*.rendered
  #private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
  private_subnets = [ for off in range(local.subnet_count) : cidrsubnet(local.cidr_block,8,off+10) ]
  #private_subnets = templatefile("${path.module}/subnet.tftpl", { cidr = local.cidr_block, nb = local.subnet_count } )
  #public_subnets =  ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets =  [ for off in range(local.subnet_count) : cidrsubnet(local.cidr_block,8,off) ]
    #templatefile("${path.module}/subnet.tftpl", {
    #  cidr_block = local.cidr_block, offset = 0, nb = local.subnet_count
    #}
    #)
  enable_nat_gateway = true

  create_database_subnet_group = false

  tags = local.common_tags
}
