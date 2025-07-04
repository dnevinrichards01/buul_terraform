resource "aws_sqs_queue" "dlq" {
  name                      = "${var.environment}-dlq"
  message_retention_seconds = 1209600 # 14 days

  policy = data.aws_iam_policy_document.sqs_access["dlq"].json
}

resource "aws_sqs_queue" "user_interaction" {
  name                       = "${var.environment}-user-interaction"
  fifo_queue                 = false
  visibility_timeout_seconds = 10
  message_retention_seconds  = 345600 # 4 days
  max_message_size           = 262144 # 256 KB
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })

  kms_master_key_id = "alias/aws/sqs" # AWS-managed key for SSE

  policy = data.aws_iam_policy_document.sqs_access["user-interaction"].json
}

resource "aws_sqs_queue" "long_running" {
  name                       = "${var.environment}-long-running"
  fifo_queue                 = false
  visibility_timeout_seconds = 10
  message_retention_seconds  = 345600 # 4 days
  max_message_size           = 262144 # 256 KB
  receive_wait_time_seconds  = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })

  kms_master_key_id = "alias/aws/sqs" # AWS-managed key for SSE

  policy = data.aws_iam_policy_document.sqs_access["long-running"].json
}

data "aws_iam_policy_document" "sqs_access" {
  for_each = toset(local.queues)
  statement {
    effect = "Allow"
    actions = [
      "SQS:SendMessage",
      "SQS:ChangeMessageVisibility",
      "SQS:DeleteMessage",
      "SQS:ReceiveMessage"
    ]
    principals {
      type        = "AWS"
      identifiers = values(var.ecs_task_role_arns)
    }
    resources = [
      "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${var.environment}-${each.key}"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:sourceVpce"
      values   = [var.vpce_ids["sqs"]]
    }
  }
}


data "aws_caller_identity" "current" {}