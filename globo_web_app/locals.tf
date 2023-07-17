locals {
  instance_prefix = "globo"
  common_tags = {
    company      = var.COMPANY
    project      = "${var.COMPANY}-${var.PROJECT}"
    billing_code = var.BILLING_CODE
  }
  main_cidr = format("%s/%s", var.vpc_netcidr, var.vpc_netsize)

  rogers = "globo-web-app-${random_integer.random-rogers.result}"
}
resource "random_integer" "random-rogers" {
  min = 10000
  max = 99999
  keepers = {
    version = 6.0
  }
}