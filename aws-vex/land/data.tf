##########
### DATA
##########
resource "aws_key_pair" "wopr4-vex-key-pair" {
  key_name   = "wopr4-vex-key-pair"
  public_key = file(var.AWS_PUBLIC_KEY_PATH)
  # pas besoin de donner la cle privee a ce niveau
}
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