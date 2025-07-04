data "aws_route53_zone" "hosted_zone" {
  name         = var.domain
  private_zone = false
}

resource "aws_route53_record" "alb_cert_validation" {
  count = 1 //length(var.domain_validation_options)

  zone_id = data.aws_route53_zone.hosted_zone.id
  name    = var.domain_validation_options[count.index].resource_record_name
  type    = var.domain_validation_options[count.index].resource_record_type
  ttl     = 60
  records = [var.domain_validation_options[count.index].resource_record_value]
}
