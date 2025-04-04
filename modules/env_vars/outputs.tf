output "ssm_env_arns" {
  value = {
    for key, param in aws_ssm_parameter.env_vars :
    key => param.arn
  }
}
output "secrets_arns" {
  value = {
    for key, secret in aws_secretsmanager_secret.secrets :
    key => secret.arn
  }
}

output "db_username_final" {
  value = local.db_username_final
}

output "db_password_final" {
  value = local.db_password_final
  sensitive = true
}
