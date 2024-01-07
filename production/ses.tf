# ===============================================================================
# SES Records
# ===============================================================================
resource "aws_ses_domain_identity" "main" {
  domain = local.domain
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "aws_ses_configuration_set" "main_event" {
  name = "${local.project}-${local.env}-ses-event"
}

resource "aws_route53_record" "ses_main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "_amazonses.${local.domain}"
  type    = "XTX"
  ttl     = 600

  records = [
    aws_ses_domain_identity.main.verification_token,
  ]
}

resource "aws_route53_record" "ses_main_dkim" {
  count   = 3
  zone_id = aws_route53_zone.main.zone_id
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${local.domain}"
  type    = "CNAME"
  ttl     = 600

  records = [
    "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com",
  ]
}

resource "aws_route53_record" "ses_spf" {
  zone_id = aws_route53_zone.main.zone_id
  name    = local.domain
  type    = "TXT"
  ttl     = 600

  records = [
    "v-spf1 include:amazonses.com ~all",
  ]
}


# ===============================================================================
# Send Events to Kinesis Firehose
# ===============================================================================
resource "aws_ses_event_destination" "firehose" {
  name                   = "${local.project}-${local.env}-ses-to-firehose"
  configuration_set_name = aws_ses_configuration_set.main_event.name
  enabled                = true

  matching_types = [
    "send",
    "reject",
    "delivery",
    "bounce",
    "complaint",
  ]

  kinesis_destination {
    stream_arn = aws_kinesis_firehose_delivery_stream.ses_event_log.arn
    role_arn   = aws_iam_role.ses.arn
  }

  depends_on = [
    aws_iam_policy.ses,
  ]
}


# ===============================================================================
# Send Events to CloudWatch Custom Metrics
# ===============================================================================
resource "aws_ses_event_destination" "cloudwatch_bounce" {
  name                   = "${local.project}-${local.env}-ses-to-cw-bounce"
  configuration_set_name = aws_ses_configuration_set.main_event.name
  enabled                = true

  matching_types = [
    "bounce",
  ]

  cloudwatch_destination {
    default_value  = "bounce"
    dimension_name = "SESBounce"
    value_source   = "messageTag"
  }

  depends_on = [
    aws_iam_policy.ses,
  ]
}

resource "aws_ses_event_destination" "cloudwatch_complaint" {
  name                   = "${local.project}-${local.env}-ses-to-cw-complaint"
  configuration_set_name = aws_ses_configuration_set.main_event.name

  matching_types = [
    "complaint",
  ]

  cloudwatch_destination {
    default_value  = "complaint"
    dimension_name = "SESComplaint"
    value_source   = "messageTag"
  }

  depends_on = [
    aws_iam_policy.ses,
  ]
}
