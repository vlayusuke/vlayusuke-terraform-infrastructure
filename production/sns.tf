# ===============================================================================
# SNS Topic for Metric Alarm
# ===============================================================================
resource "aws_sns_topic" "metric_alarm" {
  name = "${local.project}-${local.env}-sns-metric-alarm-topic"

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
    Name = "${local.project}-${local.env}-sns-metric-alarm-topic"
  }
}

resource "aws_sns_topic_policy" "metric_alarm_to_slack" {
  arn    = aws_sns_topic.metric_alarm.arn
  policy = data.aws_iam_policy_document.metric_alarm_to_slack.json
}

data "aws_iam_policy_document" "metric_alarm_to_slack" {
  statement {
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
      "sns:Receive",
    ]
    resources = [
      aws_sns_topic.metric_alarm.arn,
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
      aws_sns_topic.metric_alarm.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# SNS Topic for Event Alarm
# ===============================================================================
resource "aws_sns_topic" "event_alarm" {
  name = "${local.project}-${local.env}-sns-event-alarm-topic"

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
    Name = "${local.project}-${local.env}-sns-event-alarm-topic"
  }
}

resource "aws_sns_topic_policy" "event_alarm_to_slack" {
  arn    = aws_sns_topic.event_alarm.arn
  policy = data.aws_iam_policy_document.event_alarm_to_slack.json
}

data "aws_iam_policy_document" "event_alarm_to_slack" {
  statement {
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
      "sns:Receive",
    ]
    resources = [
      aws_sns_topic.event_alarm.arn,
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
      aws_sns_topic.event_alarm.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# SNS Topic for Inspector Notification
# ===============================================================================
resource "aws_sns_topic" "inspector_notification" {
  name = "${local.project}-${local.env}-sns-inspector-notification-topic"

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
    Name = "${local.project}-${local.env}-sns-inspector-notification-topic"
  }
}

resource "aws_sns_topic_policy" "inspector_notification_to_slack" {
  arn    = aws_sns_topic.inspector_notification.arn
  policy = data.aws_iam_policy_document.inspector_notification_to_slack.json
}

data "aws_iam_policy_document" "inspector_notification_to_slack" {
  statement {
    sid    = "SNSAccess"
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
      "sns:Receive",
    ]
    resources = [
      aws_sns_topic.inspector_notification.arn,
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
      aws_sns_topic.inspector_notification.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}


# ===============================================================================
# SNS Topic for Notification to Slack
# ===============================================================================
resource "aws_sns_topic" "to_slack" {
  name = "${local.project}-${local.env}-sns-to-slack-topic"

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
    Name = "${local.project}-${local.env}-sns-to-slack-topic"
  }
}

resource "aws_sns_topic_policy" "to_slack" {
  arn    = aws_sns_topic.to_slack.arn
  policy = data.aws_iam_policy_document.to_slack.json
}

data "aws_iam_policy_document" "to_slack" {
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
      aws_sns_topic.to_slack.arn,
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
      aws_sns_topic.to_slack.arn,
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}
