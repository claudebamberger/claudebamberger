##########
### DATA
##########
data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_ebs_volumes" "wopr_data" {
  tags = {
    role = "wopr-data"
  }
  filter {
    name   = "availability-zone"
    values = ["${data.aws_availability_zones.available.names[0]}"]
  }
  filter {
    name   = "encrypted"
    values = ["true"]
  }
}