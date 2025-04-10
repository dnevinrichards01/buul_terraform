output "ec2_arn" {
  value = aws_instance.analytics.arn
}

output "analytics_db_name_port_host" {
  value = local.analytics_db_name_port_host
}