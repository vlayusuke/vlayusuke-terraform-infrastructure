# ===============================================================================
# Chatbot
# ===============================================================================
module "sns_to_slack_via_chatbot_general" {
  source  = "waveaccounting/chatbot-slack-configuration/aws"
  version = "1.1.0"

  configuration_name = "${local.project}-${local.env}-sns-to-slack-via-chatbot-general"
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_channel_id   = var.root_slack_channel_id
  slack_workspace_id = var.root_slack_workspace_id
  logging_level      = "INFO"

  guardrail_policies = [
    aws_iam_policy.chatbot_guardrail.arn,
  ]

  sns_topic_arns = [
    aws_sns_topic.to_slack_general.arn,
    module.guardduty_virginia.sns_topic_arn,
    module.guardduty_ohio.sns_topic_arn,
    module.guardduty_california.sns_topic_arn,
    module.guardduty_oregon.sns_topic_arn,
    module.guardduty_mumbai.sns_topic_arn,
    module.guardduty_tokyo.sns_topic_arn,
    module.guardduty_seoul.sns_topic_arn,
    module.guardduty_osaka.sns_topic_arn,
    module.guardduty_singapore.sns_topic_arn,
    module.guardduty_sydney.sns_topic_arn,
    module.guardduty_canada.sns_topic_arn,
    module.guardduty_frankfurt.sns_topic_arn,
    module.guardduty_ileland.sns_topic_arn,
    module.guardduty_london.sns_topic_arn,
    module.guardduty_paris.sns_topic_arn,
    module.guardduty_stockholm.sns_topic_arn,
    module.guardduty_saopaulo.sns_topic_arn,
  ]
}
