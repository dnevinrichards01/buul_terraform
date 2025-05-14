output "ssm_env_arns" {
  value = {
    for key, param in aws_ssm_parameter.env_vars :
    key => param.arn
  }
}
output "secret_arns" {
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

output "ssm_kms_id" {
    value = aws_kms_key.ssm.arn
}

output "secret_kms_id" {
    value = aws_kms_key.secret.arn
}




output "analytics_ssm_env_arns" {
  value = {
    for key, param in aws_ssm_parameter.analytics_ssm_env_vars :
    key => param.arn
  }
}

output "analytics_secret_arns" {
  value = {
    for key, secret in aws_secretsmanager_secret.analytics_ec2_secrets :
    key => secret.arn
  }
}

output "analytics_secret_kms_id" {
    value = aws_kms_key.analytics_ec2_secret.arn
}

output "analytics_ssm_kms_id" {
    value = aws_kms_key.analytics_ssm.arn
}

//

output "proxy_ssm_env_arns" {
  value = {
    for key, param in aws_ssm_parameter.proxy_env_vars : 
    key => param.arn
  }
}

output "proxy_secret_arns" {
  value = {
    for key, secret in aws_secretsmanager_secret.proxy_secrets : 
    key => secret.arn
  }
}

output "proxy_secret_kms_id" {
    value = aws_kms_key.proxy_secret.arn
}

output "proxy_ssm_kms_id" {
    value = aws_kms_key.proxy_ssm.arn
}




