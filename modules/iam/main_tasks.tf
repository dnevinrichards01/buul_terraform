resource "aws_iam_role" "ecs_task_execution" {
  for_each = toset(local.containers)
  name = "${var.environment}-${each.value}-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
} 

data "aws_iam_policy_document" "ecs_task_logs" {
  for_each = toset(local.containers)
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
      effect  = "Allow"
      actions = [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ]
      resources = [
        "arn:aws:logs:${statement.value}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.environment}/${each.key}:log-stream:*",
        "arn:aws:logs:${statement.value}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.environment}/debug:log-stream:*"
      ]
    }
  }
}
resource "aws_iam_policy" "ecs_task_logs" {
  for_each = toset(local.containers)
  name   = "${var.environment}-${each.key}-ecs-logs"
  policy = data.aws_iam_policy_document.ecs_task_logs[each.value].json
}
resource "aws_iam_role_policy_attachment" "ecs_task_logs" {
  for_each = toset(local.containers)
  role       = aws_iam_role.ecs_task_execution[each.value].name
  policy_arn = aws_iam_policy.ecs_task_logs[each.value].arn
} 

data "aws_iam_policy_document" "ecs_exec" {
  for_each = toset(local.containers)
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
        "ecs:ExecuteCommand",
        "ssm:StartSession",
        "ssm:DescribeSessions",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
        ]
        resources = ["*"] // specify later
    }
  }
}
resource "aws_iam_policy" "ecs_exec" {
  for_each = toset(local.containers)
  name   = "${var.environment}-${each.key}-ecs-exec"
  policy = data.aws_iam_policy_document.ecs_exec[each.value].json
}
resource "aws_iam_role_policy_attachment" "ecs_exec" {
  for_each = toset(local.containers)
  role       = aws_iam_role.ecs_task_execution[each.value].name
  policy_arn = aws_iam_policy.ecs_exec[each.value].arn
} 

data "aws_iam_policy_document" "ecs_sqs" {
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
      effect  = "Allow"
      actions = [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:GetQueueAttributes"
      ]
      resources = [
        "*"
        //"arn:aws:sqs:${statement.value}:${data.aws_caller_identity.current.account_id}:ab-user-interaction",
        //"arn:aws:sqs:${statement.value}:${data.aws_caller_identity.current.account_id}:ab-long-running",
        //"arn:aws:sqs:${statement.value}:${data.aws_caller_identity.current.account_id}:ab-dlq"
      ]
    }
  }
  statement {
    effect  = "Allow"
    actions = [
      "sqs:ListQueues",
      "sqs:CreateQueue"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "ecs_sqs" {
  name   = "${var.environment}-ecs-sqs"
  policy = data.aws_iam_policy_document.ecs_sqs.json
}
resource "aws_iam_role_policy_attachment" "ecs_sqs" {
  for_each = toset(local.containers)
  role       = aws_iam_role.ecs_task_execution[each.value].name
  policy_arn = aws_iam_policy.ecs_sqs.arn
} 

data "aws_iam_policy_document" "ecs_read_secrets" {
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
      effect  = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      resources = [
        "*"
        //"arn:aws:secretsmanager:${statement.value}:${data.aws_caller_identity.current.account_id}:secret:rds!db-3b665cc1-3b69-494f-aef5-ea338c22218d-ck42Wi",
        //"arn:aws:secretsmanager:${statement.value}:${data.aws_caller_identity.current.account_id}:secret:ab-backend-email-host-password-IzkFuE",
        //"arn:aws:secretsmanager:${statement.value}:${data.aws_caller_identity.current.account_id}:secret:ab-backend-plaid-credentials-R1cjDw"
      ]
    }
  }
}
resource "aws_iam_policy" "ecs_read_secrets" {
  name   = "${var.environment}-ecs-read-secrets"
  policy = data.aws_iam_policy_document.ecs_read_secrets.json
}
resource "aws_iam_role_policy_attachment" "ecs_read_secrets" {
  for_each = toset(local.containers)
  role       = aws_iam_role.ecs_task_execution[each.value].name
  policy_arn = aws_iam_policy.ecs_read_secrets.arn
} 

data "aws_iam_policy_document" "ecs_ssm_parameter" {
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:DescribeParameters"
        ]
        resources = [
            "*"
        //"arn:aws:ssm:${statement.value}:${data.aws_caller_identity.current.account_id}:parameter/your-prefix/*"
        ]
    }
  }
}
resource "aws_iam_policy" "ecs_ssm_parameter" {
  name   = "${var.environment}-ecs-ssm-parameter"
  policy = data.aws_iam_policy_document.ecs_ssm_parameter.json
}
resource "aws_iam_role_policy_attachment" "ecs_ssm_parameter" {
  for_each = toset(local.containers)
  role       = aws_iam_role.ecs_task_execution[each.value].name
  policy_arn = aws_iam_policy.ecs_ssm_parameter.arn
} 

resource "aws_iam_role_policy_attachment" "ecs_ecr_full_access" {
  for_each = toset(local.containers)
  role       = aws_iam_role.ecs_task_execution[each.value].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  for_each = toset(local.containers)
  role       = aws_iam_role.ecs_task_execution[each.value].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



