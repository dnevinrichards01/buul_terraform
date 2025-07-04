locals {
  cloudtrail_name = "${var.environment}-cloudtrail"
  cloudtrail_s3_resource_policies = var.region == "us-west-1" ? [
    {
      Sid    = "AllowCloudTrailGetBucket"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action   = "s3:GetBucketAcl"
      Resource = "${aws_s3_bucket.regional_logs.arn}"
      Condition = {
        StringEquals = {
          "aws:SourceArn" = "arn:aws:cloudtrail:${var.region}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"
        }
      }
    },
    {
      Sid    = "AllowCloudTrailWrite"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action   = "s3:PutObject"
      Resource = "${aws_s3_bucket.regional_logs.arn}/cloudtrail/*"
      Condition = {
        StringEquals = {
          "s3:x-amz-acl"     = "bucket-owner-full-control"
          "aws:SourceArn"   = "arn:aws:cloudtrail:${var.region}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"
        }
      }
    }
  ] : []

  other_s3_resource_policies = [
    [
      {
        Sid    = "AllowALBPut"
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.regional_logs.arn}/alb/*"
      },
      {
        Sid    = "AllowVPCFlowLogsPut"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.regional_logs.arn}/AWSLogs/*"
      },
      {
        Sid    = "AllowFirehosePut"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.regional_logs.arn}/aws-waf-logs/*"
      },

      # given by AWS
      {
        Sid    = "AWSLogDeliveryWrite1"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.regional_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
            "s3:x-amz-acl"       = "bucket-owner-full-control"
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:us-west-1:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      },
      {
        Sid    = "AWSLogDeliveryAclCheck1"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "${aws_s3_bucket.regional_logs.arn}"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:us-west-1:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  ]

  s3_resource_policy = {
    Version  = "2012-10-17"
    Statement = flatten([
      local.cloudtrail_s3_resource_policies,
      local.other_s3_resource_policies
    ])
  }
}
