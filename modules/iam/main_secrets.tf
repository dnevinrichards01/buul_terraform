data "aws_iam_policy_document" "secret_policy_doc" {
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
      effect  = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      principals {
        type        = "AWS"
        // please change this soon once you get the ecs task roles
        identifiers = [
          "*"
        ]
      }
      resources = [
        "arn:aws:secretsmanager:${statement.value}:${data.aws_caller_identity.current.account_id}:secret:ecs/${var.environment}/*"
      ]
    }
  }
}

data "aws_iam_policy_document" "ssm_read_policy_doc" {
  for_each = var.ssm_env_arns

  dynamic "statement" {
    for_each = toset(var.regions)
    content {
      effect  = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      //principals {
      //  type        = "AWS"
      //  identifiers = [for task, arn in local.ecs_task_role_arns : arn]
      //}
      // ssm params resource policies doesn't allow 'principal'
      condition {
        test     = "StringEquals"
        variable = "aws:sourceVpce"
        values   = var.vpce_ids["ssm"]
      }
      resources = [for arn in var.ssm_env_arns : arn]
    }
  }
}


