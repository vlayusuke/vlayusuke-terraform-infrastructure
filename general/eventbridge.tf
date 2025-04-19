# ===============================================================================
# EventBridge (Check Config)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "check_config" {
  name           = "${local.project}-${local.env}-eb-check-config"
  description    = "Check Config Notification"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.config"
    ],
    "detail-type" : [
      "Config Rules Complete Change"
    ],
    "detail" : {
      "messageType" : [
        "ComplianceChangeNotification"
      ]
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-eb-check-config"
  }
}

resource "aws_cloudwatch_event_target" "check_config_sns" {
  rule      = aws_cloudwatch_event_rule.check_config.name
  target_id = aws_sns_topic.to_slack_audit.name
  arn       = aws_sns_topic.to_slack_audit.arn
}


# ===============================================================================
# EventBridge (CloudTrail)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "cloudtrail" {
  name           = "${local.project}-${local.env}-eb-cloudtrail"
  description    = "CloudTrail Notification"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.cloudtrail"
    ],
    "detail-type" : [
      "AWS API Call via CloudTrail"
    ],
    "detail" : {
      "eventSource" : [
        "monitoring.amazonaws.com",
        "log.amazonaws.com",
        "ec2.amazonaws.com",
        "elasticloadbalancing.amazonaws.com",
        "iam.amazonaws.com",
        "lambda.amazonaws.com",
        "s3.amazonaws.com",
        "ses.amazonaws.com",
        "sns.amazonaws.com",
        "rds.amazonaws.com",
        "signin.amazonaws.com"
      ]
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-eb-cloudtrail"
  }
}

resource "aws_cloudwatch_event_target" "cloudtrail_sns" {
  rule      = aws_cloudwatch_event_rule.cloudtrail.name
  target_id = aws_sns_topic.to_slack_audit.name
  arn       = aws_sns_topic.to_slack_audit.arn
}
