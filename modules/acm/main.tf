
// request acm cert


// maybe change this so that we create this cert for the 

resource "aws_acm_certificate" "alb" {
  domain_name       = "${var.environment}-${var.region}.${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


// create dns validation record

data "aws_route53_zone" "hosted_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "alb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.hosted_zone.id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

resource "aws_route53_record" "alb_domain" {
  zone_id = data.aws_route53_zone.hosted_zone.id
  name    = "${var.environment}-alb-domain"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

// validate cert

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
}


