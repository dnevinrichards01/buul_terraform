output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "alb_zone_id" {
  value = aws_lb.app.zone_id
}

output "kms_aliases" {
  value = {
    for env_var_name, alias in local.kms :
    env_var_name => "${var.environment}-${alias}"
  }
}