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

#module "landfill" {
#  source              = "./modules/landfill"
#  secure_cidr         = var.AWS_SECURE_CIDR
#  landfill_cidr_block = var.AWS_LANDFILL_CIDR_BLOCK
#  landfill_subnet     = var.AWS_LANDFILL_SUBNET
#}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=4.0.2,<4.1"

  tags            = { Environment = "test" }
  cidr            = "192.168.88.0/24"   #var.AWS_LANDFILL_CIDR_BLOCK
  private_subnets = ["192.168.88.0/28"] # [var.AWS_LANDFILL_SUBNET]
  public_subnets  = ["192.168.88.16/28"]

  azs = ["us-east-1a"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = false

  manage_default_vpc            = false
  manage_default_network_acl    = false
  manage_default_security_group = false

  name                        = "landfill"
  default_vpc_name            = "landfill"
  private_subnet_names        = ["landfill-private"]
  public_subnet_names         = ["landfill-public"]
  default_network_acl_name    = "landfill-ACL"
  default_route_table_name    = "landfill-RT"
  default_security_group_name = "landfill-SG"

}
module "wopr" {
  source             = "./modules/wopr"
  region             = var.AWS_REGION
  landline_subnet_id = module.vpc.public_subnets[0]
  #landline_sg_ssh_id = module.vpc.default_security_group_id
  public_key_path  = var.AWS_PUBLIC_KEY_PATH
  private_key_path = var.AWS_PRIVATE_KEY_PATH
  key_pair_id      = aws_key_pair.wopr4-vex-key-pair.id
}

output "wopr4_public_ip" {
  value = module.wopr.wopr4_manage_ip
}
output "wopr4_manage_pubkey" {
  value = aws_key_pair.wopr4-vex-key-pair.public_key
}