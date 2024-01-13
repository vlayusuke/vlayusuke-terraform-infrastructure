# ===============================================================================
# ACM
# ===============================================================================
resource "aws_acm_certificate" "main" {
  domain_name       = local.domain
  validation_method = "DNS"

  tags = {
    Name = "${local.project}-${local.env}-acm-certificate-main"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for i in aws_acm_certificate.main.domain_validation_options : i.domain_mame => {
      name   = i.resource_record_name
      record = i.resource_record_value
      type   = i.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  ttl             = 300
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id

  records = [
    each.value.record,
  ]
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn

  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation :
    record.fqdn
  ]
}
