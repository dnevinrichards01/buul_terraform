resource "aws_ssm_parameter" "env_vars" {
  for_each = local.env_vars

  name  = "/ecs/${var.environment}/${each.key}"
  type  = "String"
  value = each.value
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = local.secret_jsons
  name = "ecs/${var.environment}/${each.key}"
}

resource "aws_secretsmanager_secret_version" "secret_values" {
  for_each      = local.secret_jsons
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}

resource "aws_secretsmanager_secret_policy" "secret_policies" {
  for_each   = local.secret_jsons
  secret_arn = aws_secretsmanager_secret.secrets[each.key].arn
  policy     = var.secret_policy_doc_json
}

data "aws_secretsmanager_random_password" "db_password" {
  password_length  = 32
  exclude_characters = "/'\"@&"
}



