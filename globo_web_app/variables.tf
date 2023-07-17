variable "COMPANY" {
  type        = string
  description = "Company name"
  default     = "Globomantics"
}
variable "PROJECT" {
  type        = string
  description = "project name"
  default     = "Globo Website"
}
variable "BILLING_CODE" {
  type        = string
  description = "billing in Globo"
  default     = "G1080"
  sensitive   = true
}
variable "AWS_REGION" {
  type        = string
  description = "the AWS region to target, set a TF_VAR_AWS_REGION for that"
  default     = "us-east-1"
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
  default     = 20
  validation {
    condition     = (var.vpc_netsize >= 8) && (var.vpc_netsize <= 20)
    error_message = "vpc netsize should be between 8 and 20"
  }
}
variable "web-intances" {
  type        = number
  description = "number of web-server instances from 0 to 253"
  default     = 2
  validation {
    condition     = (var.web-intances <= 253) && (var.web-intances >= 0)
    error_message = "web-server intances count should be between 0 and 253"
  }
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