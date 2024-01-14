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

  tags = {
    Name = "${local.project}-${local.env}-acm-certificate-main"
  }
}
