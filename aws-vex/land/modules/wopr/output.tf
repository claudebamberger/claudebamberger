output "wopr4_manage_ip" {
  value = aws_eip.landip.public_ip
}
output "wopr4_id" {
  value = aws_instance.wopr4.id
}