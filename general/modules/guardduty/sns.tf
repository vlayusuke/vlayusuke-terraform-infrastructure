resource "aws_sns_topic" "guardduty" {
  name = "${var.project}-guardduty"
}

resource "aws_sns_topic_policy" "guardduty" {
  arn = aws_sns_topic.guardduty.arn

  policy = data.aws_iam_policy_document.guardduty.json
}

data "aws_iam_policy_document" "guardduty" {
  statement {
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish",
      "SNS:Receive",
    ]
    resources = [
      aws_sns_topic.guardduty.arn,
    ]
    principals {
      type = "AWS"
      identifiers = [
        "*",
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
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
      aws_sns_topic.guardduty.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}
