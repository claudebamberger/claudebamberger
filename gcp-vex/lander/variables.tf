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