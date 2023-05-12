terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

resource "aws_vpc" "landfill" {
  cidr_block       = "192.168.88.0/28"
  instance_tenancy = "default"
  tags             = { name = "landfill" }
}

resource "aws_subnet" "landlord" {
  vpc_id     = aws_vpc.landfill.id
  cidr_block = "192.168.88.0/28"
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
    cidr_blocks      = [var.AWS_SECURE_CIDR]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = { name = "landfill" }
}
resource "aws_eip" "landip" {
  vpc = true
  instance = aws_instance.wopr4.id
  depends_on = [ aws_internet_gateway.landline ]
}
resource "aws_key_pair" "myregion-wopr-key-pair" {
  key_name   = "myregion-key-pair"
  public_key = file(var.AWS_PUBLIC_KEY_PATH)
}
resource "aws_instance" "wopr4" {
  ami           = lookup(var.AMI_Ubuntu_LTS22_x86, var.AWS_REGION)
  instance_type = "t2.micro"
  # VPC
  subnet_id = aws_subnet.landlord.id
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.landline_ssh.id}"]
  # the Public SSH key
  key_name = aws_key_pair.myregion-wopr-key-pair.id
  connection {
    user        = "ubuntu"
    private_key = file("${var.AWS_PRIVATE_KEY_PATH}")
  }
}
