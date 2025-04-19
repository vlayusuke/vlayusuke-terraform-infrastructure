# ===============================================================================
# SNS Topic for Notification to Slack
# ===============================================================================
resource "aws_sns_topic" "to_slack_audit" {
  name = "${local.project}-${local.env}-sns-to-slack-audit"

  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false
    }
  })

  tags = {
    Name = "${local.project}-${local.env}-sns-to-slack-audit"
  }
}

resource "aws_sns_topic_policy" "to_slack_audit" {
  arn = aws_sns_topic.to_slack_audit.arn

  policy = data.aws_iam_policy_document.to_slack_audit.json
}

data "aws_iam_policy_document" "to_slack_audit" {
  statement {
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "SNS:Publish",
      "SNS:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:AddPermission",
      "SNS:Subscribe",
    ]
    resources = [
      aws_sns_topic.to_slack_audit.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
  }

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.to_slack_audit.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}
