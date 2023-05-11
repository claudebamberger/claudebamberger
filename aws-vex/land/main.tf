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
  // region = "us-east-1"
}

data "aws_region" "current" {}

resource "aws_vpc_ipam" "landipam" {
  operating_regions {
    region_name = data.aws_region.current.name
  }
  tags = {
    name = "landfill"
  }
}
resource "aws_vpc_ipam_pool" "landipampool" {
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.landipam.private_default_scope_id
  locale         = data.aws_region.current.name
  allocation_default_netmask_length = 28
}

resource "aws_vpc_ipam_pool_cidr" "landipampoolcidr88" {
  ipam_pool_id = aws_vpc_ipam_pool.landipampool.id
  cidr = "192.168.88.0/28"
}

resource "aws_vpc" "landfill" {
  ipv4_ipam_pool_id   = aws_vpc_ipam_pool.landipampool.id
  ipv4_netmask_length = 28
  depends_on = [
    aws_vpc_ipam_pool_cidr.landipampoolcidr
  ]
  tags = {
    name = "landfill"
  }
}

/*resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "allow ssh inbound"
  //vpc_id = aws_vpc.landfill

  ingress {
    description      = "SSH from outside"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}*/