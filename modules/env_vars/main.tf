// ssm

resource "aws_kms_key" "ssm" {
  description             = "KMS key for encrypting SSM parameters"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  policy = data.aws_iam_policy_document.ssm_kms_resource.json
}
data "aws_iam_policy_document" "ssm_kms_resource" {
  statement {
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = values(var.ecs_task_role_arns)
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:sourceVpce"
      values   = [var.vpce_ids["ssm"]]
    }
  } 
  statement {
    sid     = "EnableRootAccess"
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}
resource "aws_ssm_parameter" "env_vars" {
  for_each = local.env_vars

  name  = "/ecs/${var.environment}/${each.key}"
  type  = "SecureString"
  value = each.value
  key_id = aws_kms_key.ssm.id
}


// secrets
resource "aws_kms_key" "secret" {
  description             = "KMS CMK for encrypting Secrets Manager secrets"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  policy = data.aws_iam_policy_document.secret_kms_resource.json
}
data "aws_iam_policy_document" "secret_kms_resource" {
  statement {
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = values(var.ecs_task_role_arns)
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:sourceVpce"
      values   = [var.vpce_ids["secretsmanager"]]
    }
  }
  statement {
    sid     = "EnableRootAccess"
    effect  = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }
}
resource "aws_secretsmanager_secret" "secrets" {
  for_each = local.secret_jsons
  name = "ecs/${var.environment}/${each.key}"
  kms_key_id = aws_kms_key.secret.id
}
resource "aws_secretsmanager_secret_version" "secret_values" {
  for_each      = local.secret_jsons
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}
data "aws_iam_policy_document" "secrets_policy" {
  for_each      = local.secret_jsons
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = values(var.ecs_task_role_arns)
    }
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:sourceVpce"
      values   = [var.vpce_ids["secretsmanager"]]
    }
    resources = ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:ecs/${var.environment}/${each.key}"]
  }
}
resource "aws_secretsmanager_secret_policy" "secret_policies" {
  for_each   = local.secret_jsons
  secret_arn = aws_secretsmanager_secret.secrets[each.key].arn
  policy     = data.aws_iam_policy_document.secrets_policy[each.key].json
}


// ssm
// make only for us-west-1, make this an instance of an env_var module
//resource "aws_kms_key" "analytics_ssm" {
//  description             = "KMS key for encrypting analytics ec2 SSM parameters"
//  enable_key_rotation     = true
//  deletion_window_in_days = 10
//  policy = data.aws_iam_policy_document.analytics_ssm_kms_resource.json
//}
//data "aws_iam_policy_document" "analytics_ssm_kms_resource" {
//  statement {
//    effect  = "Allow"
//    principals {
//      type        = "AWS"
//      identifiers = [var.analytics_ec2_role_arn]
//    }
//    actions = [
//      "kms:Decrypt",
//      "kms:DescribeKey"
//    ]
//    resources = ["*"]
//    condition {
//      test     = "StringEquals"
//      variable = "aws:sourceVpce"
//      values   = [var.vpce_ids["ssm"]]
//    }
//  }
//  statement {
//    sid     = "EnableRootAccess"
//    effect  = "Allow"

//    principals {
//      type        = "AWS"
//      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
//    }

//    actions   = ["kms:*"]
//    resources = ["*"]
//  }
//}
//resource "aws_ssm_parameter" "analytics_ssm_env_vars" {
//  for_each = local.analytics_ec2_env_vars

//  name  = "/analytics/${var.environment}/${each.key}"
//  type  = "SecureString"
//  value = each.value
//  key_id = aws_kms_key.analytics_ssm.id
//}


// secrets
//resource "aws_kms_key" "analytics_ec2_secret" {
//  description             = "KMS CMK for encrypting analytics ec2 Secrets Manager secrets"
//  enable_key_rotation     = true
//  deletion_window_in_days = 10
//  policy = data.aws_iam_policy_document.secret_kms_resource.json
//}
//data "aws_iam_policy_document" "analytics_ec2_secret_kms_resource" {
//  statement {
//    effect  = "Allow"
//    principals {
//      type        = "AWS"
//      identifiers = [var.analytics_ec2_role_arn]
//    }
//    actions = [
//      "kms:Decrypt",
//      "kms:DescribeKey"
//    ]
//    resources = ["*"]
//    condition {
//      test     = "StringEquals"
//      variable = "aws:sourceVpce"
//      values   = [var.vpce_ids["secretsmanager"]]
//    }
//  }
//  statement {
//    sid     = "EnableRootAccess"
//    effect  = "Allow"

//    principals {
//      type        = "AWS"
//      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
//    }

//    actions   = ["kms:*"]
//    resources = ["*"]
//  }
//}
//resource "aws_secretsmanager_secret" "analytics_ec2_secrets" {
//  for_each = local.analytics_ec2_secret_jsons
//  name = "analytics/${var.environment}/${each.key}"
//  kms_key_id = aws_kms_key.secret.id
//}
//resource "aws_secretsmanager_secret_version" "analytics_ec2_secrets_values" {
//  for_each      = local.analytics_ec2_secret_jsons
//  secret_id     = aws_secretsmanager_secret.analytics_ec2_secrets[each.key].id
//  secret_string = each.value
//}
//data "aws_iam_policy_document" "analytics_ec2_secrets_policy" {
//  for_each      = local.analytics_ec2_secret_jsons
//  statement {
//    effect = "Allow"
//    principals {
//      type        = "AWS"
//      identifiers = [var.analytics_ec2_role_arn]
//    }
//    actions = [
//      "secretsmanager:GetSecretValue",
//      "secretsmanager:DescribeSecret"
//    ]
//    condition {
//      test     = "StringEquals"
//      variable = "aws:sourceVpce"
//      values   = [var.vpce_ids["secretsmanager"]]
//    }
//    resources = ["arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:analytics/${var.environment}/${each.key}"]
//  }
//}
//resource "aws_secretsmanager_secret_policy" "analytics_ec2_secrets_policies" {
//  for_each   = local.analytics_ec2_secret_jsons
//  secret_arn = aws_secretsmanager_secret.analytics_ec2_secrets[each.key].arn
//  policy     = data.aws_iam_policy_document.analytics_ec2_secrets_policy[each.key].json
//}

data "aws_caller_identity" "current" {}



