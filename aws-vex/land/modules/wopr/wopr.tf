resource "aws_instance" "wopr4" {
  # TODO AMI lookup :
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
  ami           = lookup(var.AMI_Ubuntu_LTS22_x86, var.region)
  instance_type = "t2.micro"
  # VPC
  subnet_id = var.landline_subnet_id
  # TODO: comprendre pourquoi il associe de toutes façon une IP publique au final
  associate_public_ip_address = var.associate_public_ip_address
  # Security Group
  vpc_security_group_ids = var.landline_sg_ids
  # not in VPC security_groups = [var.landline_sg_ssh_id]
  # TODO: private_dns_name_options et private_dns
  # the Public SSH key
  key_name = var.key_pair_id
  tags = {
    name = "wopr-${var.name}"
  }
  #connection { # inutile avec keyname…
  #  user        = "ubuntu"
  #  private_key = file("var.private_key_path")
  #}
  #autre methode (marche pas)
  # user_data = <<EOT
#!/bin/bash
#
#touch /home/ubuntu/user_data_was_here
#date "+INSTANCE SETUP DATE: %Y-%m-%d TIME: %H:%M:%S.%3N"
#sudo apt-get update && sudo apt-get full-upgrade -y
#
#EOT
}
resource "aws_eip" "landip" {
  # NB: on doit aligner associate_public_ip_address sur l'instance et map_public_ip_on_launch sur la vpc
  count    = var.associate_public_ip_address ? 1 : 0
  vpc      = true
  instance = aws_instance.wopr4.id
}
