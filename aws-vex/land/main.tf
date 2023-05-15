terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}
provider "aws" {
  region = var.AWS_REGION
}

resource "aws_key_pair" "wopr4-vex-key-pair" {
  key_name   = "wopr4-vex-key-pair"
  public_key = file(var.AWS_PUBLIC_KEY_PATH)
}

module "landfill" {
  source              = "./modules/landfill"
  secure_cidr         = var.AWS_SECURE_CIDR
  landfill_cidr_block = var.AWS_LANDFILL_CIDR_BLOCK
  landfill_subnet     = var.AWS_LANDFILL_SUBNET
}
module "wopr" {
  source             = "./modules/wopr"
  region             = var.AWS_REGION
  landline_subnet_id = module.landfill.landline_subnet_id
  landline_sg_ssh_id = module.landfill.landline_sg_ssh_id
  public_key_path    = var.AWS_PUBLIC_KEY_PATH
  private_key_path   = var.AWS_PRIVATE_KEY_PATH
  key_pair_id        = aws_key_pair.wopr4-vex-key-pair.id
}
output "wopr4_public_ip" {
  value = module.wopr.wopr4_manage_ip
}
output "wopr4_manage_pubkey" {
  value = aws_key_pair.wopr4-vex-key-pair.public_key
}