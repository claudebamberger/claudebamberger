##################################################################################
# RESOURCES
##################################################################################

# BUCKET #

resource "aws_s3_bucket" "buck" {
  bucket        = local.rogers
  force_destroy = true
  tags          = local.common_tags
}

resource "aws_s3_object" "sally_index" {
  bucket = aws_s3_bucket.buck.bucket
  key    = "/website/index.html"
  source = "./website/index.html"
  tags   = local.common_tags
}
resource "aws_s3_object" "sally_graphic" {
  bucket = aws_s3_bucket.buck.bucket
  key    = "/website/Globo_logo_Vert.png"
  source = "./website/Globo_logo_Vert.png"
  tags   = local.common_tags
}

# IAM #
resource "aws_iam_role" "allow_nginx_s3" {
  name               = "allow_nginx_s3"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags               = local.common_tags
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name
  tags = local.common_tags
}

resource "aws_iam_role_policy" "allow_s3_all" {
  name   = "allow_s3_all"
  role   = aws_iam_role.allow_nginx_s3.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${local.rogers}",
                "arn:aws:s3:::${local.rogers}/*"
            ]
    }
  ]
}
EOF
}

resource "aws_s3_bucket_policy" "buckpolicy" {
  bucket = aws_s3_bucket.buck.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.root.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.rogers}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.rogers}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${local.rogers}"
    }
  ]
}
    POLICY
}