##################################################################################
# PROVIDERS
##################################################################################
provider "aws" {
  #access_key nope
  #secret_key nope
  region = var.AWS_REGION
  default_tags {
    tags = local.common_tags
  }
}
provider "random" {}