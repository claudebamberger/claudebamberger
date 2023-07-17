resource "aws_vpc" "landfill" {
  cidr_block       = var.landfill_cidr_block
  instance_tenancy = "default"
  tags             = { name = "landfill" }
}
resource "aws_subnet" "landlord" {
  vpc_id     = aws_vpc.landfill.id
  cidr_block = var.landfill_subnet
  tags       = { name = "landfill" }
}
resource "aws_internet_gateway" "landline" {
  vpc_id = aws_vpc.landfill.id
  tags   = { name = "landfill" }
}
resource "aws_route_table" "landline" {
  vpc_id = aws_vpc.landfill.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.landline.id
  }
  tags = { name = "landfill" }
}
resource "aws_route_table_association" "landline" {
  subnet_id      = aws_subnet.landlord.id
  route_table_id = aws_route_table.landline.id
}
resource "aws_security_group" "landline_ssh" {
  vpc_id = aws_vpc.landfill.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "SSH from outside"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.secure_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = { name = "landfill" }
}