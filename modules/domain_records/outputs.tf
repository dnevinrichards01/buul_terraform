output "hosted_zone_id" {
  value = data.aws_route53_zone.hosted_zone.id
}

output "validation_record_fqdns" {
  value = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
}