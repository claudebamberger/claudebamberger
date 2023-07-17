##################################################################################
# DATA
##################################################################################

data "aws_elb_service_account" "root" {}

##################################################################################
# RESOURCES
##################################################################################

# LB #
# aws_lb
resource "aws_lb" "globolb" {
  name               = "GloboWeb-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_albsg.id]
  subnets            = slice(module.vpc.public_subnets, 1, length(module.vpc.public_subnets))
  # or aws_subnet.public_subnet[*].id
  enable_deletion_protection = false
  depends_on                 = [module.s3_buckets.buck_policy]
  access_logs {
    bucket  = module.s3_buckets.buck.id
    prefix  = "alb-logs"
    enabled = true
  }
  tags = local.common_tags
}
# aws_lb_target_group
resource "aws_lb_target_group" "globolbtg" {
  name     = "lgobolbtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  tags     = local.common_tags
}
# aws_lb_listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.globolb.arn
  port              = "80"
  protocol          = "HTTP"
  tags              = local.common_tags
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.globolbtg.arn
  }
}
# aws_lb_target_group_attachement
resource "aws_lb_target_group_attachment" "globo_attach" {
  target_group_arn = aws_lb_target_group.globolbtg.arn
  target_id        = aws_instance.nginx[count.index].id
  port             = 80
  count            = var.web-intances
}