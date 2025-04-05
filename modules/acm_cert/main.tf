// regional cert validation
resource "aws_acm_certificate" "alb" {
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"] 
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    force_recreate = "yes"
  }
}
resource "aws_acm_certificate_validation" "alb" {
  certificate_arn         = aws_acm_certificate.alb.arn
  validation_record_fqdns = var.validation_record_fqdns
}




