resource "aws_iam_role" "analytics_ec2" {
  name = "${var.environment}-analytics-ec2"

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

data "aws_iam_policy_document" "analytics_ec2_read_secrets" {
  dynamic "statement" {
    for_each = toset(var.regions)
    content {
      effect  = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      resources = [
        for secret, arn in var.analytics_secret_arns : arn
        //"arn:aws:secretsmanager:${statement.value}:${data.aws_caller_identity.current.account_id}:secret:analytics/${var.environment}/${secret}"
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
        resources = [var.analytics_secret_kms_id]
    }
  }
}
resource "aws_iam_policy" "analytics_ec2_read_secrets" {
  name   = "${var.environment}-analytics-ec2-read-secrets"
  policy = data.aws_iam_policy_document.analytics_ec2_read_secrets.json
}
resource "aws_iam_role_policy_attachment" "analytics_ec2_read_secrets" {
  role       = aws_iam_role.analytics_ec2.name
  policy_arn = aws_iam_policy.analytics_ec2_read_secrets.arn
} 

data "aws_iam_policy_document" "analytics_ec2_ssm_parameter" {
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
            for env_var, arn in var.analytics_ssm_env_arns : arn
            //"arn:aws:ssm:${statement.value}:${data.aws_caller_identity.current.account_id}:parameter/analytics/${var.environment}/${env_var}"
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
        resources = [var.analytics_ssm_kms_id]
    }
  }
}
resource "aws_iam_policy" "analytics_ec2_ssm_parameter" {
  name   = "${var.environment}-analytics-ec2-ssm-parameter"
  policy = data.aws_iam_policy_document.analytics_ec2_ssm_parameter.json
}
resource "aws_iam_role_policy_attachment" "analytics_ec2_ssm_parameter" {
  role       = aws_iam_role.analytics_ec2.name
  policy_arn = aws_iam_policy.analytics_ec2_ssm_parameter.arn
} 

// kms here too

resource "aws_iam_role_policy_attachment" "analytics_ec2_ssm_session" {
  role       = aws_iam_role.analytics_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

