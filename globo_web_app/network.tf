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
#resource "aws_vpc" "app" {
#  cidr_block           = format("%s/%s", var.vpc_netcidr, var.vpc_netsize)
#  enable_dns_hostnames = true
#  tags                 = local.common_tags
#}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=4.0, <6.0"
  name    = "app"
  cidr    = local.main_cidr
  azs     = slice(data.aws_availability_zones.azs.names, 0, min(length(data.aws_availability_zones.azs), var.web-intances))
  public_subnets = [
    for index in range(var.web-intances+1) : cidrsubnet(local.main_cidr, 8, index)
  ]
  enable_nat_gateway      = false
  enable_vpn_gateway      = false
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true
  tags                    = local.common_tags
}
# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx_sg" {
  name   = "nginx_sg"
  vpc_id = module.vpc.vpc_id
  # HTTP access from anywhere
  ingress {
    from_port   = var.httpport
    to_port     = var.httpport
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}
# LB Securiy group
resource "aws_security_group" "nginx_albsg" {
  name   = "nginx_albsg"
  vpc_id = module.vpc.vpc_id
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
  tags = local.common_tags
}

# admin security groups
resource "aws_security_group" "nginx_admin" {
  name   = "nginx_admin"
  vpc_id = module.vpc.vpc_id
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
  tags = local.common_tags
}

resource "aws_security_group" "admin_nginx" {
  name   = "admin_nginx"
  vpc_id = module.vpc.vpc_id
  # HTTP access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${cidrsubnet(module.vpc.vpc_cidr_block, 8, 0)}"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}