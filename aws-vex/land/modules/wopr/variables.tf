variable "region" {
  description = "région AWS visée, exported shell"
  type        = string
}
variable "name" {
  description = "nom à utiliser a minima dans les tags"
  type        = string
}
variable "landline_subnet_id" {
  description = "le subnet dans lequel spawner l'instance"
  type        = string
}
variable "associate_public_ip_address" {
  description = "lui faut-il une IP publique"
  type        = bool
}
variable "landline_sg_ids" {
  description = "les security groupes from outside"
  type        = set(string)
}
variable "public_key" {
  description = "chemin de la clé publique (pour la région), exported shell (optional future use)"
  type        = string
}
variable "ansible_public_key" {
  description = "clé publique ansible"
  type        = string
}
variable "cloud_init_addon" {
  description = "script spécifique à ajouter en fin d'init"
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
variable "AMI_Ubuntu_LTS22_arm64" {
  type        = map(string)
  description = "AMI pour Ubuntu LTS 22.04 sur ARM64"
  default = {
    us-east-1    = "ami-0c6c29c5125214c77"
    eu-central-1 = "ami-07625524674f7c390"
    eu-west-3    = "ami-0bd3b255f1beeae5e"
  }
}