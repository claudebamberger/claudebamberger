variable "AWS_REGION" {
  description = "région AWS visée, exported shell"
  type        = string
}
variable "AWS_SECURE_CIDR" {
  description = "CIDR sûr en entrée, exported shell"
  type        = string
}
variable "AMI_Ubuntu_LTS22_x86" {
  type        = map(string)
  description = "AMI pour Ubuntu LTS 22.04 sur x86"
  default = {
    us-east-1    = "ami-007855ac798b5175e"
    eu-central-1 = "ami-0ec7f9846da6b0f61"
    eu-west-3    = "ami-05e8e219ac7e82eba"
  }
}
variable "AWS_PUBLIC_KEY_PATH" {
  description = "chemin de la clé publique (pour la région), exported shell"
  type        = string
}
variable "AWS_PRIVATE_KEY_PATH" {
  description = "chemin de la clé privée (pour la région), exported shell"
  type        = string
}