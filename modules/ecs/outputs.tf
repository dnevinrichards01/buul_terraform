output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "alb_zone_id" {
  value = aws_lb.app.zone_id
}

output "alb_arn" {
  value = aws_lb.app.arn
}

output "kms_aliases" {
  value = {
    for env_var_name, alias in local.kms :
    env_var_name => "alias/${var.environment}-${alias}"
  }
}

output "kms_arns" {
  value = [for kms_env_var_name, kms in aws_kms_key.db_encryption : kms.arn]
}