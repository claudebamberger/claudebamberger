output "landline_sg_ssh_id" {
  value = aws_security_group.landline_ssh.id
}
output "landline_subnet_id" {
  value = aws_subnet.landlord.id
}
output "landline_vpc_id" {
  value = aws_vpc.landfill.id
}