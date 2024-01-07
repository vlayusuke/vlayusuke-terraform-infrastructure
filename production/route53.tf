# ===============================================================================
# Route 53 Host Zone
# ===============================================================================
resource "aws_route53_zone" "main" {
  name    = local.domain
  comment = "Amazon Route 53 Host Zone managed by Terraform"

  tags = {
    Name = "${local.project}-${local.env}-route-53-main-host-zone"
  }
}


# ===============================================================================
# Route 53 Record
# ===============================================================================
resource "aws_route53_record" "main_A" {
  zone_id = aws_route53_zone.main.id
  name    = local.domain
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "main_AAAA" {
  zone_id = aws_route53_zone.main.id
  name    = local.domain
  type    = "AAAA"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
