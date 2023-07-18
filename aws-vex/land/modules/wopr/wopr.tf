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
}
resource "aws_eip" "landip" {
  # TODO: count 0 si var.associate_public_ip_address false
  count    = var.associate_public_ip_address ? 1 : 0
  vpc      = true
  instance = aws_instance.wopr4.id
}
