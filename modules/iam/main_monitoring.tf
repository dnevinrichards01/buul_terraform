# flog logs

resource "aws_iam_role" "flow_logs_role" {
  name = "${var.environment}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "vpc-flow-logs.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["s3:PutObject"],
      Resource = "${var.cloudtrail_bucket_arn}/*"
    }]
  })
}


# network firewall setup role


// some policies given to configurer, not the emitter (the service)
// that's why we are using a role_policy
// although the emitter will still need resource permissions in s3
resource "aws_iam_role_policy" "network_firewall_log_setup" {
  name = "NetworkFirewallLogDeliveryPolicy"
  role = aws_iam_role.network_firewall_logging_setup_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Sid: "FirewallLogging",
        Effect: "Allow",
        Action: [
          "logs:CreateLogDelivery",
          "logs:GetLogDelivery",
          "logs:UpdateLogDelivery",
          "logs:DeleteLogDelivery",
          "logs:ListLogDeliveries"
        ],
        Resource: "*"
      },
      {
        Sid: "FirewallLoggingS3",
        Effect: "Allow",
        Action: [
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy"
        ],
        Resource: var.monitoring_logs_bucket_arns
      }
    ]
  })
}
// allows the user to temporarily assume this role
resource "aws_iam_role" "network_firewall_logging_setup_role" {
  name = "${var.environment}-network-firewall-log-delivery-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          AWS: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${data.aws_iam_user.terraform_role.user_name}"
        },
        Action: "sts:AssumeRole"
      }
    ]
  })
}



# firehose (waf for alb)

resource "aws_iam_role" "firehose_delivery_role" {
  name = "${var.environment}-firehose-delivery-role"
  
  //"waf.amazonaws.com"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement : [{
      Effect = "Allow",
      Principal = {
        Service = [
          "firehose.amazonaws.com"
        ]
      },
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "firehose_delivery_policy_s3" {
  name = "${var.environment}-firehose-delivery-policy-s3"
  role = aws_iam_role.firehose_delivery_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Resource : [for arn in var.monitoring_logs_bucket_arns : "${arn}/*"]
      }
    ]
  })
}
resource "aws_iam_role_policy" "firehose_delivery_policy_kinesis" {
  name = "${var.environment}-firehose-delivery-policy-kinesis"
  role = aws_iam_role.firehose_delivery_role.id

  for_each = toset(var.regions)

  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListShards"
        ],
        Resource : "arn:aws:kinesis:${each.value}:${data.aws_caller_identity.current.account_id}:stream/aws-waf-log-${var.environment}-${each.value}"
      }
    ]
  })
}


resource "aws_iam_role_policy" "waf_logging_setup_policy" {
  name = "WAFLoggingSetupPolicy"
  role = aws_iam_role.waf_logging_setup_policy_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Sid: "AllowWAFLoggingSetup",
        Effect: "Allow",
        Action: [
          "iam:CreateServiceLinkedRole",
          "firehose:ListDeliveryStreams",
          "wafv2:PutLoggingConfiguration"
        ],
        Resource: "*"
      }
    ]
  })
}
resource "aws_iam_role" "waf_logging_setup_policy_role" {
  name = "${var.environment}-waf-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Principal: {
          AWS: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${data.aws_iam_user.terraform_role.user_name}"
        },
        Action: "sts:AssumeRole"
      }
    ]
  })
}


data "aws_iam_user" "terraform_role" {
  user_name = "Nevin"
}
