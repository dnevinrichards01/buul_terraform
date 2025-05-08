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
      resources = compact([
        "arn:aws:logs:${statement.value}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.environment}/${each.key}:log-stream:*",
        each.key == "app" ? "arn:aws:logs:${statement.value}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.environment}/debug-latest:log-stream:*" : null,
        each.key == "app" ? "arn:aws:logs:${statement.value}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.environment}/debug-current:log-stream:*" : null
      ])
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


// kms here too
data "aws_iam_policy_document" "ecs_exec" {
  for_each = toset(local.containers)
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
            "ssm:StartSession",
            "ssm:DescribeSessions",
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
        ]
        resources = ["*"]
        //condition {
        //    test     = "StringEquals"
        //    variable = "aws:sourceVpce"
        //    values   = concat(var.vpce_ids["ssm"], var.vpce_ids["ssmmessages"])
        //}
    }
  }
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
            "ecs:ExecuteCommand"
        ]
        resources = ["arn:aws:ecs:${statement.value}:${data.aws_caller_identity.current.account_id}:task-definition/${var.environment}-${each.value}:*"]
        //condition {
        //    test     = "StringEquals"
        //    variable = "aws:sourceVpce"
        //    values   = concat(var.vpce_ids["ssm"], var.vpce_ids["ssmmessages"])
        //}
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


// kms here too?
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
        for queue in local.queues :
        "arn:aws:sqs:${statement.value}:${data.aws_caller_identity.current.account_id}:${var.environment}-${queue}"
      ]
    }
  }
  //statement {
  //  effect  = "Allow"
  //  actions = [
  //    "sqs:ListQueues",
  //    "sqs:CreateQueue"
  //  ]
  //  resources = ["*"]
  //}
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
        for secret, arn in var.secret_arns : arn
        //"arn:aws:secretsmanager:${statement.value}:${data.aws_caller_identity.current.account_id}:secret:ecs/${var.environment}/${secret}"
      ]
    }
  }
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
            "kms:Decrypt",
            "kms:DescribeKey"
        ]
        resources = var.secret_kms_ids
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
            for env_var, arn in var.ssm_env_arns : arn
            //"arn:aws:ssm:${statement.value}:${data.aws_caller_identity.current.account_id}:parameter/ecs/${var.environment}/${env_var}"
        ]
    }
  }
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
            "kms:Decrypt",
            "kms:DescribeKey"
        ]
        resources = var.ssm_kms_ids
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

data "aws_iam_policy_document" "db_encryption_kms" {
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
            "kms:Decrypt",
            "kms:DescribeKey"
        ]
        resources = var.ecs_kms_arns
    } 
  }
}
resource "aws_iam_policy" "db_encryption_kms" {
  name   = "${var.environment}-ecs-db-kms-encryption"
  policy = data.aws_iam_policy_document.db_encryption_kms.json
}
resource "aws_iam_role_policy_attachment" "db_encryption_kms" {
  for_each = toset(local.containers)
  role       = aws_iam_role.ecs_task_execution[each.value].name
  policy_arn = aws_iam_policy.db_encryption_kms.arn
} 


// do kms here for ecr???

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


resource "aws_iam_role_policy_attachment" "ecs_ssm_session" {
  for_each = toset(local.containers)
  role       = aws_iam_role.ecs_task_execution[each.value].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

