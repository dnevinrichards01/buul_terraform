resource "aws_sqs_queue" "dlq" {
  name                      = "${var.environment}-dlq"
  message_retention_seconds = 1209600 # 14 days

  policy = var.sqs_access_policy_doc_json["dlq"]
}

resource "aws_sqs_queue" "user_interaction" {
  name                       = "${var.environment}-user-interaction"
  fifo_queue                 = false
  visibility_timeout_seconds = 10
  message_retention_seconds  = 345600 # 4 days
  max_message_size      = 262144  # 256 KB
  receive_wait_time_seconds = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })

  kms_master_key_id = "alias/aws/sqs" # AWS-managed key for SSE

  policy = var.sqs_access_policy_doc_json["user-interaction"]
}

resource "aws_sqs_queue" "long_running" {
  name                       = "${var.environment}-long-running"
  fifo_queue                 = false
  visibility_timeout_seconds = 10
  message_retention_seconds  = 345600 # 4 days
  max_message_size      = 262144  # 256 KB
  receive_wait_time_seconds = 20

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })

  kms_master_key_id = "alias/aws/sqs" # AWS-managed key for SSE

  policy = var.sqs_access_policy_doc_json["long-running"]
}