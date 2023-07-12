##################################################################################
# DATA
##################################################################################
data "aws_availability_zones" "azs" {
  state = "available"
}
##################################################################################
# RESOURCES
##################################################################################

# NETWORKING #
resource "aws_vpc" "app" {
  cidr_block           = format("%s/%s", var.vpc_netcidr, var.vpc_netsize)
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
}

resource "aws_subnet" "public_subnet1" {
  cidr_block              = var.public_netcidr[0]
  vpc_id                  = aws_vpc.app.id
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet2" {
  cidr_block              = var.public_netcidr[1]
  vpc_id                  = aws_vpc.app.id
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnetA" {
  cidr_block              = var.public_netcidr[2]
  vpc_id                  = aws_vpc.app.id
  availability_zone       = data.aws_availability_zones.azs.names[2]
  map_public_ip_on_launch = true
}

# ROUTING #
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
}

resource "aws_route_table_association" "app_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "app_subnet2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "app_subnetA" {
  subnet_id      = aws_subnet.public_subnetA.id
  route_table_id = aws_route_table.app.id
}
# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx_sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.app.id
  # HTTP access from anywhere
  ingress {
    from_port   = var.httpport
    to_port     = var.httpport
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.app.cidr_block]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# LB Securiy group
resource "aws_security_group" "nginx_albsg" {
  name   = "nginx_albsg"
  vpc_id = aws_vpc.app.id
  # HTTP access from anywhere
  ingress {
    from_port   = var.httpport
    to_port     = var.httpport
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# admin security groups
resource "aws_security_group" "nginx_admin" {
  name   = "nginx_admin"
  vpc_id = aws_vpc.app.id
  # HTTP access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "admin_nginx" {
  name   = "admin_nginx"
  vpc_id = aws_vpc.app.id
  # HTTP access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.public_netcidr[2]}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}