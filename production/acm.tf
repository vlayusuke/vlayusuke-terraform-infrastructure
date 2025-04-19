# ===============================================================================
# ACM
# ===============================================================================
resource "aws_acm_certificate" "production" {
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
    Name = "${local.project}-${local.env}-acm-certificate"
  }
}

resource "aws_route53_record" "production" {
  for_each = {
    for dvo in aws_acm_certificate.production.domain_validation_options : dvo.domain_name => {
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
  zone_id = aws_route53_zone.production.zone_id
}

resource "aws_acm_certificate_validation" "production" {
  certificate_arn = aws_acm_certificate.production.arn
  validation_record_fqdns = [
    for record in aws_route53_record.production :
    record.fqdn
  ]
}


# ===============================================================================
# ACM for CloudFront
# ===============================================================================
resource "aws_acm_certificate" "production_cloudfront" {
  domain_name       = local.domain
  validation_method = "DNS"
  provider          = aws.virginia

  validation_option {
    domain_name       = local.domain
    validation_domain = local.domain
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${local.project}-${local.env}-acm-certificate-cf"
  }
}

resource "aws_route53_record" "production_cloudfront" {
  for_each = {
    for dvocf in aws_acm_certificate.production_cloudfront.domain_validation_options : dvocf.domain_name => {
      name   = dvocf.resource_record_name
      record = dvocf.resource_record_value
      type   = dvocf.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records = [
    each.value.record,
  ]
  ttl     = 60
  type    = each.value.type
  zone_id = aws_route53_zone.production.zone_id
}

resource "aws_acm_certificate_validation" "production_cloudfront" {
  provider        = aws.virginia
  certificate_arn = aws_acm_certificate.production_cloudfront.arn
  validation_record_fqdns = [
    for record in aws_route53_record.production :
    record.fqdn
  ]
}
