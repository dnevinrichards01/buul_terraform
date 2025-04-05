output "acm_cert_arn" {
  value = aws_acm_certificate_validation.alb.certificate_arn
}

output "domain_validation_options" {
  value = aws_acm_certificate.alb.domain_validation_options
}