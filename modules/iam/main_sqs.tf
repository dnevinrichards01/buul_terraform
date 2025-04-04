data "aws_iam_policy_document" "sqs_access" {
  for_each = toset(local.queues)
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
            "SQS:SendMessage",
            "SQS:ChangeMessageVisibility",
            "SQS:DeleteMessage",
            "SQS:ReceiveMessage"
        ]
        principals {
            type = "AWS"
            identifiers = [
                for container in local.containers : 
                local.ecs_task_role_arns[container]
            ]
        }
        resources = [
            "arn:aws:sqs:${statement.key}:${data.aws_caller_identity.current.account_id}:${var.environment}-${each.key}"
        ]
    }
  }
}

