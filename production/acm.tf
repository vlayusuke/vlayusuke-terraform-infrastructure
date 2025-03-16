# ===============================================================================
# ACM
# ===============================================================================
resource "aws_acm_certificate" "main" {
  domain_name       = local.domain
  validation_method = "DNS"

  validation_option {
    domain_name       = local.domain
    validation_domain = local.domain
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.project}-${local.env}-acm-certificate-main"
  }
}

resource "aws_route53_record" "main" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records = [
    each.value.record,
  ]
  ttl     = 60
  type    = each.value.type
  zone_id = aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn
  validation_record_fqdns = [
    for record in aws_route53_record.main : record.fqdn
  ]
}
