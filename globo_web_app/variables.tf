variable "COMPANY" {
  type        = string
  description = "Company name"
  #default    = "Globomantics"
}
variable "PROJECT" {
  type        = string
  description = "project name"
  #default    = "Globo Website"
}
variable "BILLING_CODE" {
  type        = string
  description = "billing in Globo"
  #default    = "#2652"
  sensitive = true
}
variable "AWS_REGION" {
  type        = string
  description = "the AWS region to target, set a TF_VAR_AWS_REGION for that"
  #default     = "us-east-1"
}
variable "AWS_PUBLIC_KEY_PATH" {
  type        = string
  description = "key to connect"
  #default     = "~/…"
}
variable "vpc_netcidr" {
  type        = string
  description = "beginning of vpc network"
  default     = "10.0.0.0"
}
variable "vpc_netsize" {
  type        = number
  description = "size of vpc network"
  default     = 16
}
variable "public_netcidr" {
  type        = list(string)
  description = "beginning of subnets (inside vpc network)"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.0.0/24"]
}
variable "instance_type" {
  type        = string
  description = "type of AWS instance"
  default     = "t2.micro"
}
variable "httpport" {
  type        = number
  description = "port for the nginx server to listen to"
  default     = 80
}