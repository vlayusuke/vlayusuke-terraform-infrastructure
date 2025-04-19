# ===============================================================================
# Chatbot (Amazon Q Developer)
# ===============================================================================
resource "aws_chatbot_slack_channel_configuration" "notification_slack_audit" {
  configuration_name          = "${local.project}-${local.env}-sns-via-chatbot-audit"
  iam_role_arn                = aws_iam_role.chatbot.arn
  slack_channel_id            = var.audit_slack_channel_id
  slack_team_id               = var.audit_slack_workspace_id
  logging_level               = "INFO"
  user_authorization_required = false

  guardrail_policy_arns = [
    aws_iam_policy.chatbot_guardrail.arn,
  ]

  sns_topic_arns = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-sns-via-chatbot-audit"
  }
}
