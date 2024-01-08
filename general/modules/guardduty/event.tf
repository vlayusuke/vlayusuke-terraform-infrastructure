resource "aws_cloudwatch_event_rule" "guardduty" {
  name = "${var.project}-guardduty"

  event_pattern = jsonencode({
    "source" : [
      "aws.guardduty",
    ],
    "detail-type" : [
      "GuardDuty Finding",
    ]
  })
}

resource "aws_cloudwatch_event_target" "guardduty_to_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty.id
  target_id = aws_sns_topic.guardduty.name
  arn       = aws_sns_topic.guardduty.arn
}
