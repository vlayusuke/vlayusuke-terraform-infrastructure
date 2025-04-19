# ===============================================================================
# EventBridge (ECR Image Scan Notification)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "ecr_image_scan" {
  name           = "${local.project}-${local.env}-eb-ecr-image-scan"
  description    = "ECR Image Scan Notification"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.ecr"
    ],
    "detail-type" : [
      "ECR Image Scan"
    ]
  })

  tags = {
    Name = "${local.project}-${local.env}-eb-ecr-image-scan"
  }
}

resource "aws_cloudwatch_event_target" "ecr_image_scan" {
  rule      = aws_cloudwatch_event_rule.ecr_image_scan.name
  target_id = aws_sns_topic.to_slack.name
  arn       = aws_sns_topic.to_slack.arn
}
