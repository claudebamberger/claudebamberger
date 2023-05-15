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
module "landfill" {
  source      = "./modules/landfill"
  secure_cidr = var.AWS_SECURE_CIDR
}
resource "aws_eip" "landip" {
  vpc      = true
  instance = aws_instance.wopr4.id
}
resource "aws_key_pair" "wopr4-vex-key-pair" {
  key_name   = "wopr4-vex-key-pair"
  public_key = file(var.AWS_PUBLIC_KEY_PATH)
}
resource "aws_instance" "wopr4" {
  ami           = lookup(var.AMI_Ubuntu_LTS22_x86, var.AWS_REGION)
  instance_type = "t2.micro"
  # VPC
  subnet_id = module.landfill.landline_subnet_id
  # Security Group
  vpc_security_group_ids = [module.landfill.landline_sg_ssh_id]
  # the Public SSH key
  key_name = aws_key_pair.wopr4-vex-key-pair.id
  
  #connection { # TBC
  #  user        = "ubuntu"
  #  private_key = file("${var.AWS_PRIVATE_KEY_PATH}")
  #}
}
output "wopr4_manage_ip" {
  value = aws_eip.landip.public_ip
}
output "wopr4_manage_pubkey" {
  value = aws_key_pair.myregion-wopr-key-pair.public_key
}
