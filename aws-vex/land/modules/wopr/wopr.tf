##########
### AMI
##########
resource "aws_instance" "wopr4" {
  lifecycle {
    ignore_changes = [ami]
  }
  // alternative : ami = lookup(var.AMI_Ubuntu_LTS22_x86, var.region)
  ami = data.aws_ami.ubuntu.image_id
  instance_type = "t2.micro"
  subnet_id = var.landline_subnet_id
  # NB: on doit aligner associate_public_ip_address sur l'instance et map_public_ip_on_launch sur la vpc
  associate_public_ip_address = var.associate_public_ip_address
  private_ip = var.private_ip_address
  # Security Group
  vpc_security_group_ids = var.landline_sg_ids
  # the Public SSH key
  key_name = aws_key_pair.wopr4-key-pair.id
  tags = {
    name = "wopr-${var.name}"
  }
  user_data = <<EOT
#!/bin/bash
date "+WOPR SETUP DATE: %Y-%m-%d TIME: %H:%M:%S.%3N"
sudo useradd --gid operator --groups sudo --create-home ansible
sudo mkdir /home/ansible/.ssh
sudo sh -c 'echo "${var.ansible_public_key}" > /home/ansible/.ssh/authorized_keys'
sudo mkdir /wopr4
sudo apt-get update && sudo apt-get full-upgrade -y
sudo apt-get install -y cowsay zip unzip net-tools inetutils-ping dnsutils vim ufw cron ansible neofetch
${var.cloud_init_addon}
EOT
}
resource "aws_key_pair" "wopr4-key-pair" {
  key_name   = "wopr4-key-pair-${var.name}"
  public_key =  var.public_key
  # pas besoin de donner la cle privee a ce niveau
}
resource "aws_eip" "landip" {
  # NB: on doit aligner associate_public_ip_address sur l'instance et map_public_ip_on_launch sur la vpc
  count    = var.associate_public_ip_address ? 1 : 0
  # deprecated vpc      = true
  # replaced by
  domain   = "vpc"
  instance = aws_instance.wopr4.id
}
