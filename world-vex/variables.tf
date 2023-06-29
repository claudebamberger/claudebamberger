variable "AWS_REGION" {
  description = "région AWS visée, exported shell"
  type        = string
}
variable "AWS_SECURE_CIDR" {
  description = "CIDR sûr en entrée, exported shell"
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
variable "AWS_LANDFILL_SUBNET_PUBLIC" {
  description = "CIDR correspondant au sous-réseau public"
  type        = string
  default     = "192.168.88.16/28"
}
variable "GCP_PROJECT_ID" {
  description = "Projet GCP visé, exported shell"
  type        = string
}
variable "GCP_REGION" {
  description = "région GCP visée, exported shell"
  type        = string
}
variable "GCP_SECURE_CIDR" {
  description = "CIDR sûr en entrée, exported shell"
  type        = string
  sensitive   = true
}
variable "GCP_PUBLIC_KEY_PATH" {
  description = "chemin de la clé publique (pour la région), exported shell"
  type        = string
}
variable "GCP_PRIVATE_KEY_PATH" {
  description = "chemin de la clé privée (pour la région), exported shell"
  type        = string
}
variable "GCP_LANDER_CIDR_BLOCK" {
  description = "CIDR correspondant au réseau"
  type        = string
  default     = "192.168.88.0/24"
}
variable "GCP_LANDER_SUBNET_PUBLIC" {
  description = "CIDR correspondant au sous-réseau"
  type        = string
  default     = "192.168.88.16/28"
}
variable "GCP_LANDER_SUBNET_PRIVATE" {
  description = "CIDR correspondant au sous-réseau"
  type        = string
  default     = "192.168.88.0/28"
}
