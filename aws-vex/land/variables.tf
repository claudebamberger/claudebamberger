variable "AWS_REGION" {
  description = "région AWS visée, exported shell"
  type        = string
}
variable "AWS_SECURE_CIDR" {
  description = "CIDR sûr en entrée, exported shell"
  type        = string
  sensitive   = true
}
variable "AWS_MYDOMAIN" {
  description = "Domaine racine des noms publics"
  type        = string
  sensitive   = true
}
variable "AWS_PUBLIC_KEY_PATH" {
  description = "chemin de la clé publique (pour la région), exported shell"
  type        = string
}
variable "AWS_PRIVATE_KEY_PATH" {
  description = "chemin de la clé privée (pour la région), exported shell"
  type        = string
}
variable "AWS_ANSIBLE_KEY" {
  description = "clé publique ansible"
  type        = string
}
variable "AWS_LANDFILL_CIDR_BLOCK" {
  description = "CIDR correspondant au réseau"
  type        = string
  default     = "192.168.88.0/24"
}
variable "AWS_LANDFILL_SUBNET_PRIVE" {
  description = "CIDR correspondant au sous-réseau privé"
  type        = string
  default     = "192.168.88.0/28"
}
variable "AWS_WOPRPRIV_PRIVATE_IP" {
  description = "IP privée de woprPriv"
  type        = string
  default     = "192.168.88.8"
}
variable "AWS_LANDFILL_SUBNET_PUBLIC" {
  description = "CIDR correspondant au sous-réseau public"
  type        = string
  default     = "192.168.88.16/28"
}
variable "AWS_WOPRPUB_PRIVATE_IP" {
  description = "IP privée de woprPub"
  type        = string
  default     = "192.168.88.20"
}