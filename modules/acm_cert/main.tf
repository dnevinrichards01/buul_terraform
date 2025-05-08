resource "aws_acm_certificate" "alb" {
  domain_name       = "${var.environment}.${var.domain}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = var.validation_record_fqdns
}


