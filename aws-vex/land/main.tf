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
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_ebs_volumes" "wopr_data" {
  tags = {
    role = "wopr-data"
  }
  filter {
    name   = "availability-zone"
    values = ["${data.aws_availability_zones.available.names[0]}"]
  }
  filter {
    name   = "encrypted"
    values = ["true"]
  }
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=4.0.2,<4.1"

  tags            = { Environment = "test" }
  cidr            = var.AWS_LANDFILL_CIDR_BLOCK
  private_subnets = ["${var.AWS_LANDFILL_SUBNET_PRIVE}"]
  public_subnets  = ["${var.AWS_LANDFILL_SUBNET_PUBLIC}"]

  azs = ["${data.aws_availability_zones.available.names[0]}"]

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
resource "aws_security_group" "landline_ssh" {
  vpc_id = module.vpc.vpc_id
  name   = "landline_external"
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description = "SSH from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks      = ["0.0.0.0/0"]
    cidr_blocks      = ["${var.AWS_SECURE_CIDR}"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = { name = "landfill" }
}
resource "aws_security_group" "landfill_ssh" {
  vpc_id = module.vpc.vpc_id
  name   = "landfill_internal"
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::1/128"]
  }
  ingress {
    description      = "SSH from inside ipv4"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.AWS_LANDFILL_SUBNET_PRIVE}", "${var.AWS_LANDFILL_SUBNET_PUBLIC}"]
    ipv6_cidr_blocks = ["::1/128"]
  }
  tags = { name = "landfill" }
}

module "woprPub" {
  source             = "./modules/wopr"
  region             = var.AWS_REGION
  landline_subnet_id = module.vpc.public_subnets[0]
  name               = "pub"
  landline_sg_ssh_id = aws_security_group.landline_ssh.id
  key_pair_id        = aws_key_pair.wopr4-vex-key-pair.id
}
module "woprPriv" {
  source             = "./modules/wopr"
  region             = var.AWS_REGION
  landline_subnet_id = module.vpc.private_subnets[0]
  name               = "priv"
  landline_sg_ssh_id = aws_security_group.landfill_ssh.id
  key_pair_id        = aws_key_pair.wopr4-vex-key-pair.id
}
resource "aws_route53_zone" "primary" {
  name = var.AWS_MYDOMAIN
}
resource "aws_route53_record" "wopr-ssh" {
  zone_id = aws_route53_zone.primary.zone_id
  weighted_routing_policy {
    weight = 1
  }
  name           = "aws.${var.AWS_MYDOMAIN}"
  type           = "A"
  ttl            = 300
  set_identifier = "aws"
  records        = [module.woprPub.wopr4_manage_ip]
}
resource "aws_volume_attachment" "ebs_att" {
  count       = length(data.aws_ebs_volumes.wopr_data.ids[*]) == 1 ? 1 : 0
  device_name = "/dev/sdm"
  volume_id   = data.aws_ebs_volumes.wopr_data.ids[0]
  instance_id = module.woprPriv.wopr4_id
}
output "wopr4_public_ip" {
  value = "${module.woprPub.wopr4_manage_ip}"
}
output "wopr4priv_internal_ip" {
  value = module.woprPriv.wopr4_internal_ip
}
output "wopr4_manage_pubkey" {
  value = aws_key_pair.wopr4-vex-key-pair.public_key
}
output "domain_name_servers" {
  description = "NameServers vs ns-640.awsdns-16.net & ns-1077.awsdns-06.org"
  value       = aws_route53_zone.primary.name_servers
}