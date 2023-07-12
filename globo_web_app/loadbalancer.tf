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
  name                       = "GloboWeb-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.nginx_albsg.id]
  subnets                    = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  enable_deletion_protection = false
  depends_on                 = [aws_s3_bucket_policy.buckpolicy]
  access_logs {
    bucket  = aws_s3_bucket.buck.bucket
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
  vpc_id   = aws_vpc.app.id
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
resource "aws_lb_target_group_attachment" "globo_attach1" {
  target_group_arn = aws_lb_target_group.globolbtg.arn
  target_id        = aws_instance.nginx1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "globo_attach2" {
  target_group_arn = aws_lb_target_group.globolbtg.arn
  target_id        = aws_instance.nginx2.id
  port             = 80
}
