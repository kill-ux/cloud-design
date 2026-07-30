output "cert_arn" {
  value = aws_acm_certificate.api_cert.arn
}

output "cert_validation_record" {
  value = one(aws_acm_certificate.api_cert.domain_validation_options)
}