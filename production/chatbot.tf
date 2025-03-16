# ===============================================================================
# Chatbot (Amazon Q Developer)
# ===============================================================================
resource "aws_chatbot_slack_channel_configuration" "notification_slack" {
  configuration_name = "${local.project}-${local.env}-sns-via-chatbot"
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_channel_id   = var.slack_channel_id
  slack_team_id      = var.slack_workspace_id
  logging_level      = "INFO"

  guardrail_policy_arns = [
    aws_iam_policy.chatbot_guardrail.arn,
  ]

  sns_topic_arns = [
    aws_sns_topic.metric_alarm.arn,
    aws_sns_topic.event_alarm.arn,
    aws_sns_topic.inspector_notification.arn,
    aws_sns_topic.to_slack.arn,
  ]
}
