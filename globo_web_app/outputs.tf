##################################################################################
# OUTPUTS
##################################################################################

output "public_hostname" {
  value       = "http://${aws_lb.globolb.dns_name}"
  description = "Public Hostname"
}
output "admin_gateway" {
  value = "ssh-agent ; ssh-agent add ${var.AWS_PUBLIC_KEY_PATH} ; ssh -A ec2-user@${aws_instance.admin.public_ip}"
  description = "Admin gateway"
}
output "web-servers" {
  value = "${aws_instance.nginx[*].private_ip}"
  description = "web-servers"
}