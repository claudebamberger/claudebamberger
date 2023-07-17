variable "bucket_name" {
  type = string
  description = "name of the bucket (unique)"
}

variable "common_tags" {
   type = map(string)
   description = "tags to apply"
}

variable "lbARN" {
   type = string
   description = "ARN of the LB"
}