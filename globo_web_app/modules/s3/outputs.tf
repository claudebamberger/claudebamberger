output "buck" {
  description = "bucket to use"
  value = aws_s3_bucket.buck
}
output "nginx_s3_profile" {
  description = "profile for NGinx"
  value = aws_iam_instance_profile.nginx_profile.name
}
output "nginx_s3_policy" {
  description = "policy for NGinx"
  value = aws_iam_role_policy.allow_s3_all
}
output "buck_policy" {
  description = "policy for LB"
  value = aws_s3_bucket_policy.buckpolicy.id
}
