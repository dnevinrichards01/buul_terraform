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


//assign this to ecs task probably 

resource "aws_iam_policy" "ssm_read_policy" {
  name   = "ecs-read-env"
  policy = data.aws_iam_policy_document.ssm_read_policy_doc.json
}
data "aws_iam_policy_document" "ssm_read_policy_doc" {
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
      effect  = "Allow"
      actions = [
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath"
      ]
      resources = [
        "arn:aws:ssm:${statement.value}:${data.aws_caller_identity.current.account_id}:parameter/ecs/${var.environment}/*"
      ]
    }
  }
}
