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
variable "private_ip_address" {
  description = "IP privée (null si pas besoin)"
  type        = string
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