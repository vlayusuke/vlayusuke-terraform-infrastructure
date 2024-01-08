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
      "Config Rules Compliance Change"
    ],
    "detail" : {
      "messageType" : [
        "ComplianceChangeNotification"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "check_config_sns" {
  target_id = aws_sns_topic.to_slack_general.id
  rule      = aws_cloudwatch_event_rule.check_config.name
  arn       = aws_sns_topic.to_slack_general.arn
}
