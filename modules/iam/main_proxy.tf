resource "aws_iam_role" "proxy_task_execution" {
  name = "${var.environment}-proxy"

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


data "aws_iam_policy_document" "proxy_read_secrets" {
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
      effect  = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      resources = [
        for secret, arn in var.proxy_secret_arns : arn
        //"arn:aws:secretsmanager:${statement.value}:${data.aws_caller_identity.current.account_id}:secret:proxy/${var.environment}/${secret}"
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
        resources = var.proxy_secret_kms_ids
    }
  }
}
resource "aws_iam_policy" "proxy_read_secrets" {
  name   = "${var.environment}-proxy-read-secrets"
  policy = data.aws_iam_policy_document.proxy_read_secrets.json
}
resource "aws_iam_role_policy_attachment" "proxy_read_secrets" {
  role       = aws_iam_role.proxy_task_execution.name
  policy_arn = aws_iam_policy.proxy_read_secrets.arn
} 

data "aws_iam_policy_document" "proxy_ssm_parameter" {
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
            for env_var, arn in var.proxy_ssm_env_arns : arn
            //"arn:aws:ssm:${statement.value}:${data.aws_caller_identity.current.account_id}:parameter/proxy/${var.environment}/${env_var}"
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
        resources = var.proxy_ssm_kms_ids
    }
  }
}
resource "aws_iam_policy" "proxy_ssm_parameter" {
  name   = "${var.environment}-proxy-ssm-parameter"
  policy = data.aws_iam_policy_document.proxy_ssm_parameter.json
}
resource "aws_iam_role_policy_attachment" "proxy_ssm_parameter" {
  role       = aws_iam_role.proxy_task_execution.name
  policy_arn = aws_iam_policy.proxy_ssm_parameter.arn
} 

// kms here too

resource "aws_iam_role_policy_attachment" "proxy_ssm_session" {
  role       = aws_iam_role.proxy_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}



///////


data "aws_iam_policy_document" "proxy_task_logs" {
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
        "arn:aws:logs:${statement.value}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.environment}/proxy:log-stream:*",
        "arn:aws:logs:${statement.value}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.environment}/proxy-debug-latest:log-stream:*",
        "arn:aws:logs:${statement.value}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.environment}/proxy-debug-current:log-stream:*"
      ])
    }
  }
}
resource "aws_iam_policy" "proxy_task_logs" {
  name   = "${var.environment}-proxy-ecs-logs"
  policy = data.aws_iam_policy_document.proxy_task_logs.json
}
resource "aws_iam_role_policy_attachment" "proxy_task_logs" {
  role       = aws_iam_role.proxy_task_execution.name
  policy_arn = aws_iam_policy.proxy_task_logs.arn
} 


// kms here too
data "aws_iam_policy_document" "proxy_exec" {
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
        condition {
            test     = "StringEquals"
            variable = "aws:sourceVpce"
            values   = concat(var.vpce_ids["ssm"], var.vpce_ids["ssmmessages"])
        }
    }
  }
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
            "ecs:ExecuteCommand"
        ]
        resources = ["arn:aws:ecs:${statement.value}:${data.aws_caller_identity.current.account_id}:task-definition/${var.environment}-proxy:*"]
        condition {
            test     = "StringEquals"
            variable = "aws:sourceVpce"
            values   = concat(var.vpce_ids["ssm"], var.vpce_ids["ssmmessages"])
        }
    }
  }
}
resource "aws_iam_policy" "proxy_exec" {
  name   = "${var.environment}-proxy-ecs-exec"
  policy = data.aws_iam_policy_document.proxy_exec.json
}
resource "aws_iam_role_policy_attachment" "proxy_exec" {
  role       = aws_iam_role.proxy_task_execution.name
  policy_arn = aws_iam_policy.proxy_exec.arn
}


// kms here too?
data "aws_iam_policy_document" "proxy_sqs" {
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
resource "aws_iam_policy" "proxy_sqs" {
  name   = "${var.environment}-proxy-sqs"
  policy = data.aws_iam_policy_document.proxy_sqs.json
}
resource "aws_iam_role_policy_attachment" "proxy_sqs" {
  role       = aws_iam_role.proxy_task_execution.name
  policy_arn = aws_iam_policy.proxy_sqs.arn
} 

data "aws_iam_policy_document" "proxy_db_encryption_kms" {
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
        effect  = "Allow"
        actions = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:DescribeKey"
        ]
        resources = var.ecs_kms_arns
    } 
  }
}
resource "aws_iam_policy" "proxy_db_encryption_kms" {
  name   = "${var.environment}-proxy-db-kms-encryption"
  policy = data.aws_iam_policy_document.proxy_db_encryption_kms.json
}
resource "aws_iam_role_policy_attachment" "proxy_db_encryption_kms" {
  role       = aws_iam_role.proxy_task_execution.name
  policy_arn = aws_iam_policy.proxy_db_encryption_kms.arn
} 


// do kms here for ecr???

resource "aws_iam_role_policy_attachment" "proxy_ecr_full_access" {
  role       = aws_iam_role.proxy_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
} 
resource "aws_iam_role_policy_attachment" "proxy_ecs_task_execution" {
  role       = aws_iam_role.proxy_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


