##########
### VPC
##########
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=4.0.2,<4.1"

  tags            = { Environment = "test" }
  cidr            = var.AWS_LANDFILL_CIDR_BLOCK
  private_subnets = ["${var.AWS_LANDFILL_SUBNET_PRIVE}"]
  public_subnets  = ["${var.AWS_LANDFILL_SUBNET_PUBLIC}"]

  azs = ["${data.aws_availability_zones.available.names[0]}"]

  enable_nat_gateway     = false
  single_nat_gateway     = true
  one_nat_gateway_per_az = true
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true

  map_public_ip_on_launch       = false
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
##########
### Instances
##########
module "woprPub" {
  source                      = "./modules/wopr"
  region                      = var.AWS_REGION
  landline_subnet_id          = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  name                        = "pub"
  landline_sg_ids             = [aws_security_group.landline_ssh.id, aws_security_group.landfill_proxy.id]
  key_pair_id                 = aws_key_pair.wopr4-vex-key-pair.id
}
module "woprPriv" {
  # TODO: https://doc.ubuntu-fr.org/tinyproxy
  # TODO: https://doc.ubuntu-fr.org/proxy_terminal
  source             = "./modules/wopr"
  region             = var.AWS_REGION
  landline_subnet_id = module.vpc.private_subnets[0]
  # TODO: probleme si false, associe quand meme
  associate_public_ip_address = false
  name                        = "priv"
  landline_sg_ids             = [aws_security_group.landfill_ssh.id]
  key_pair_id                 = aws_key_pair.wopr4-vex-key-pair.id

  depends_on = [ module.woprPub ]
}
##########
### DNS
##########
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
##########
### Volume attachement
### NB fdisk -l 
##########
resource "aws_volume_attachment" "ebs_att" {
  # TODO: https://doc.ubuntu-fr.org/mount_fstab
  count       = length(data.aws_ebs_volumes.wopr_data.ids[*]) == 1 ? 1 : 0
  device_name = "/dev/sdm"
  volume_id   = data.aws_ebs_volumes.wopr_data.ids[0]
  instance_id = module.woprPriv.wopr4_id
}
##########
### Outputs (readable)
##########
output "wopr4_public_ip" {
  value = module.woprPub.wopr4_manage_ip
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