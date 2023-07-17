module "s3_buckets" {
  source      = "./modules/s3"
  bucket_name = local.rogers
  common_tags = local.common_tags
  lbARN       = data.aws_elb_service_account.root.arn
}