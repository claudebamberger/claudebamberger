##########
### AMI
##########
# DONE AMI lookup :
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
/*variable "AMI_Ubuntu_LTS22_x86" {
  type        = map(string)
  description = "AMI pour Ubuntu LTS 22.04 sur x86"
  default = {
    us-east-1    = "ami-007855ac798b5175e"
    eu-central-1 = "ami-0ec7f9846da6b0f61"
    eu-west-3    = "ami-05e8e219ac7e82eba"
  }
}
variable "AMI_Ubuntu_LTS22_arm64" {
  type        = map(string)
  description = "AMI pour Ubuntu LTS 22.04 sur ARM64"
  default = {
    us-east-1    = "ami-0c6c29c5125214c77"
    eu-central-1 = "ami-07625524674f7c390"
    eu-west-3    = "ami-0bd3b255f1beeae5e"
  }
}*/
/* <imageId>ami-0fae77c9f45683e75</imageId>
   <imageLocation>amazon/ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-20260313</imageLocation>
   <imageOwnerId>099720109477</imageOwnerId>
   <creationDate>2026-03-14T22:29:06.000Z</creationDate>
   <architecture>x86_64</architecture>
   <name>ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-20260313</name>
   <description>Canonical, Ubuntu Minimal, 24.04, amd64 noble image</description>
*/
/* 
  IL FAUT UTILISER tf state taint pour "forcer" l'upgrade d'image
*/

data "aws_ami" "ubuntu" {
  # La dernière version OK
  most_recent = true
  owners = ["099720109477"] # Canonical
  filter {
    name   = "architecture"
    values = ["x86_64"] # A voir selon la cible
  }
  filter {
    name   = "name"
    values = ["*24*"]
  }
  filter {
    name   = "description"
    values = ["*Canonical*Ubuntu*Minimal*24*LTS*"]
  }
}
/* data "aws_ami" "stable_ubuntu" {
  filter {
    name = "description"
    values = "Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2023-03-25" # A voir selon la cible
  }
}*/
### Recherche des AMIs qui "fittent" (attn surtout des vielles versions)
/*data "aws_ami_ids" "ubuntus" {
  owners = ["099720109477"] # Canonical
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["*ubuntu-jammy-22*"]
  }
  filter {
    name   = "description"
    values = ["*Canonical*Ubuntu*22*LTS*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "creation-date"
    values = ["2023-*"]
  }
}
data "aws_ami" "readubuntus" {
  for_each = toset(data.aws_ami_ids.ubuntus.ids)
  filter {
    name   = "image-id"
    values = [each.value]
  }
}
*/