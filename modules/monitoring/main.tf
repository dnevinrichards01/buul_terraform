# flow logs

resource "aws_flow_log" "vpc_flow_log" {
  vpc_id               = var.vpc_id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.regional_logs.arn
  // iam_role_arn         = var.flow_logs_role_arn // only for cloudwatch
}


# cloudtrail

resource "aws_cloudtrail" "global" {
  count = var.region == "us-west-1" ? 1 : 0

  name                          = local.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.regional_logs.id
  s3_key_prefix                 = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}


# GuardDuty

resource "aws_guardduty_detector" "main" {
  enable = true
}
resource "aws_cloudwatch_event_rule" "guardduty_finding" {
  name        = "${var.environment}-${var.region}-guardduty-finding-rule"
  description = "Trigger on GuardDuty findings"
  event_pattern = jsonencode({
    source = ["aws.guardduty"],
    detail-type = ["GuardDuty Finding"]
  })
}
resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_finding.name
  target_id = "${var.environment}-${var.region}-send-to-sns"
  arn       = aws_sns_topic.guardduty_alerts.arn
}
resource "aws_sns_topic" "guardduty_alerts" {
  name = "${var.environment}-${var.region}-security-alerts"
}
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.guardduty_alerts.arn
  protocol  = "email"
  endpoint  = "nevinrichards@bu-ul.com" 
}




# alb waf

resource "aws_wafv2_web_acl" "app" {
  name  = "${var.environment}-${var.region}-alb-waf"
  scope = "REGIONAL" # use CLOUDFRONT for CloudFront

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "exampleWebACL"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
}
//resource "aws_wafv2_web_acl_association" "app" {
//  resource_arn = var.app_alb_arn
//  web_acl_arn  = aws_wafv2_web_acl.app.arn
//}
//resource "aws_wafv2_web_acl_logging_configuration" "app" {
//  //depends_on = [aws_kinesis_firehose_delivery_stream.waf_logs]
//  log_destination_configs = [aws_kinesis_firehose_delivery_stream.waf_logs.arn]
//  resource_arn            = aws_wafv2_web_acl.app.arn
//}
//resource "aws_kinesis_firehose_delivery_stream" "waf_logs" {
//  name        = "aws-waf-log-${var.environment}-${var.region}"
//  destination = "extended_s3"
//
//  extended_s3_configuration {
//    role_arn           = var.firehose_delivery_role_arn
//    bucket_arn         = aws_s3_bucket.regional_logs.arn
//    prefix             = "aws-waf-logs"
//    buffering_size     = 5
//    buffering_interval = 300
//    compression_format = "UNCOMPRESSED"
//  }
//}



# s3

resource "aws_s3_bucket" "regional_logs" {
  bucket = "${var.environment}-${var.region}-regional-logs"
}
resource "aws_s3_bucket_public_access_block" "regional_logs" {
  bucket = aws_s3_bucket.regional_logs.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_lifecycle_configuration" "regional_logs" {
  bucket = aws_s3_bucket.regional_logs.id

  rule {
    id     = "archive-and-delete"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 180
    }
  }
}
resource "aws_s3_bucket_policy" "regional_logs" {
  bucket = aws_s3_bucket.regional_logs.id
  policy = jsonencode(local.s3_resource_policy)
  depends_on = [
    aws_s3_bucket.regional_logs,
    data.aws_caller_identity.current
  ]
}

data "aws_caller_identity" "current" {}

