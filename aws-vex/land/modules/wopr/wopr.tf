resource "aws_instance" "wopr4" {
  ami           = lookup(var.AMI_Ubuntu_LTS22_x86, var.region)
  instance_type = "t2.micro"
  # VPC
  subnet_id = var.landline_subnet_id
  # Security Group
  vpc_security_group_ids = [var.landline_sg_ssh_id]
  # the Public SSH key
  key_name = var.key_pair_id

  #connection { # inutile avec keyname…
  #  user        = "ubuntu"
  #  private_key = file("var.private_key_path")
  #}
}
resource "aws_eip" "landip" {
  vpc      = true
  instance = aws_instance.wopr4.id
}

