output "wopr4_manage_ip" {
  description = "Managed (public) IP address"
  value = var.associate_public_ip_address ? try (aws_eip.landip[0].public_ip) : "127.0.0.1"
}
output "wopr4_internal_ip" {
  description = "Private IP address"
  value = aws_instance.wopr4.private_ip
}
output "wopr4_id" {
  description = "Instance ID"
  value = aws_instance.wopr4.id
}