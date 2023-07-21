##########
### Network security
##########
locals {
  allIPv4     = "0.0.0.0/0"
  allIPv6     = "::/0"
  localhostv4 = "127.0.0.1/8"
  localhostv6 = "::1/128"
}
resource "aws_security_group" "landline_ssh" {
  # access from outside (only ssh)
  vpc_id = module.vpc.vpc_id
  name   = "landline_external"
  ingress {
    description = "SSH from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #alternative : cidr_blocks      = ["0.0.0.0/0"]
    cidr_blocks      = ["${var.AWS_SECURE_CIDR}"]
    ipv6_cidr_blocks = ["${local.localhostv6}"]
  }
  tags = { name = "landline" }
}
resource "aws_security_group" "landfill_ssh" {
  # access ONLY from inside (and only ssh)
  vpc_id = module.vpc.vpc_id
  name   = "landfill_internal"
  ingress {
    description      = "SSH from inside ipv4"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.AWS_LANDFILL_SUBNET_PRIVE}", "${var.AWS_LANDFILL_SUBNET_PUBLIC}"]
    ipv6_cidr_blocks = ["::1/128"]
  }
  tags = { name = "landfill_ssh" }
}
resource "aws_security_group" "landfill_proxy" {
  # access ONLY from inside (and only proxy)
  vpc_id = module.vpc.vpc_id
  name   = "landfill_proxy"
  ingress {
    description      = "TinyProxy from inside ipv4"
    from_port        = 8888
    to_port          = 8888
    protocol         = "tcp"
    cidr_blocks      = ["${var.AWS_LANDFILL_SUBNET_PRIVE}", "${var.AWS_LANDFILL_SUBNET_PUBLIC}"]
    ipv6_cidr_blocks = ["${local.localhostv6}"]
  }
  tags = { name = "landfill_proxy" }
}