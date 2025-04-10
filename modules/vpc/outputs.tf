output "alb_subnet_ids" {
  value = local.alb_subnet_ids
}

output "app_subnet_ids" {
  value = local.app_subnet_ids
}

output "data_subnet_ids" {
  value = local.data_subnet_ids
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "sg_alb_id" {
  value = aws_security_group.alb.id
}

output "sg_app_id" {
  value = aws_security_group.app.id
}

output "sg_data_id" {
  value = aws_security_group.data.id
}

output "sg_analytics_id" {
  value = aws_security_group.analytics.id
}

output "sg_analyticsdb_id" {
  value = aws_security_group.analyticsdb.id
}

output "vpce_ids" {
  value = local.vpce_ids
}