# ================================================================================
# Route 53 Host Zone
# ================================================================================
resource "aws_route53_zone" "production" {
  name    = local.domain
  comment = "Amazon Route 53 Host Zone for ${local.project}-${local.env}"

  tags = {
    Name = "${local.project}-${local.env}-route-53-host-zone"
  }
}


# ================================================================================
# Route 53 Record
# ================================================================================
resource "aws_route53_record" "production_A" {
  zone_id = aws_route53_zone.production.id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_lb.production_external.dns_name
    zone_id                = aws_lb.production_external.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "production_AAAA" {
  zone_id = aws_route53_zone.production.id
  name    = local.domain
  type    = "AAAA"

  alias {
    name                   = aws_lb.production_external.dns_name
    zone_id                = aws_lb.production_external.zone_id
    evaluate_target_health = true
  }
}
