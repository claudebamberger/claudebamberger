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
  private_ip_address          = var.AWS_WOPRPUB_PRIVATE_IP
  name                        = "pub"
  landline_sg_ids             = [aws_security_group.landline_ssh.id, aws_security_group.landfill_proxy.id]
  public_key                  = file(var.AWS_PUBLIC_KEY_PATH)
  ansible_public_key          = var.AWS_ANSIBLE_KEY
  cloud_init_addon            = <<EOT
hostname wopr4
sudo apt-get install -y tinyproxy
sudo sh -c 'cat /etc/tinyproxy/tinyproxy.conf | sed "s/\#Allow 192\.168\.0\.0\/16/Allow 192.168.0.0\/16/g" > /etc/tinyproxy/tinyproxy.conf2'
sudo sh -c 'cat /etc/tinyproxy/tinyproxy.conf2 | sed "s/\#Allow 172\.16\.0\.0\/12/Allow 172.16.0.0\/12/g" > /etc/tinyproxy/tinyproxy.conf3'
sudo sh -c 'cat /etc/tinyproxy/tinyproxy.conf3 | sed "s/\#Allow 10\.0\.0\.0\/8/Allow 10.0.0.0\/8/g" > /etc/tinyproxy/tinyproxy.conf'
sudo rm /etc/tinyproxy/tinyproxy.conf2 /etc/tinyproxy/tinyproxy.conf3
sudo chown tinyproxy:tinyproxy /var/log/tinyproxy
sudo systemctl restart tinyproxy
EOT
}
module "woprPriv" {
  # TODO: https://doc.ubuntu-fr.org/tinyproxy
  # TODO: https://doc.ubuntu-fr.org/proxy_terminal
  source             = "./modules/wopr"
  region             = var.AWS_REGION
  landline_subnet_id = module.vpc.private_subnets[0]
  # TODO: probleme si false, associe quand meme
  associate_public_ip_address = false
  private_ip_address          = var.AWS_WOPRPRIV_PRIVATE_IP
  name                        = "priv"
  landline_sg_ids             = [aws_security_group.landfill_ssh.id]
  public_key                  = file(var.AWS_PUBLIC_KEY_PATH)
  ansible_public_key          = var.AWS_ANSIBLE_KEY
  depends_on                  = [module.woprPub]
  cloud_init_addon            = <<EOT
sudo sh -c 'echo "Acquire::http::proxy \"http://${module.woprPub.wopr4_internal_ip}:8888/\";" > /etc/apt/apt.conf.d/60.tinyproxy.conf'
timeout 300 sh -c 'export http_proxy=http://${module.woprPub.wopr4_internal_ip}:8888; curl aws.com; while [ $? != 0 ]; do sleep 30; curl aws.com; done '
sudo apt-get update && sudo apt-get full-upgrade -y
sudo apt-get install -y git cowsay zip unzip net-tools ufw ansible ansible-lint neofetch
sudo sh -c 'echo "export http_proxy=http://${module.woprPub.wopr4_internal_ip}:8888" >> /etc/profile'
sudo mount /dev/xvdm /wopr4
grep "\/wopr4" /etc/fstab 
if [ $? != 0 ]; then
  sudo sh -c 'echo "UUID="$(blkid /dev/xvdm|sed "s/^.* UUID=\"\([^\"]*\)\".*$/\1/g")"\t/wopr4\tbtrfs\tdefaults,nofail\t0 1" >> /etc/fstab'
fi
sudo mount -a
sudo sh -c 'if [ ! -L /root/data ]; then ln -s /wopr4/root /root/data; fi'
sudo sh -c 'if [ ! -L /home/ubuntu/data ]; then ln -s /wopr4/ubuntu /home/ubuntu/data; fi'
sudo sh -c 'if [ ! -L /home/ansible/data ]; then ln -s /wopr4/ansible /home/ansible/data; fi'
sudo chown -R ansible:operator /wopr4/ansible
sudo sh -c 'echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-ansible'
EOT
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
output "domain_name_servers" {
  value       = "${join("& ", aws_route53_zone.primary.name_servers)} \nvs ns-640.awsdns-16.net & ns-1077.awsdns-06.org set on domain"
}