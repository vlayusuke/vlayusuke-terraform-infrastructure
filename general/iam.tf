# ===============================================================================
# IAM Require MFA
# ===============================================================================
resource "aws_iam_policy" "require_mfa" {
  name   = "${local.project}-${local.env}-iam-require-mfa-policy"
  policy = data.aws_iam_policy_document.require_mfa.json
}

data "aws_iam_policy_document" "require_mfa" {
  statement {
    sid    = "IAMAccess"
    effect = "Allow"
    actions = [
      "iam:UploadSSHPublicKey",
      "iam:UpdateSSHPublicKey",
      "iam:UpdateAccessKey",
      "iam:ResyncMFADevice",
      "iam:ListSSHPublicKeys",
      "iam:ListMFADevices",
      "iam:ListAccessKeys",
      "iam:GetSSHPublicKey",
      "iam:EnableMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:DeleteSSHPublicKey",
      "iam:DeleteAccessKey",
      "iam:DeactivateMFADevice",
      "iam:CreateVirtualMFADevice",
      "iam:CreateAccessKey",
      "iam:ChangePassword",
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}",
      "arn:aws:iam::*:mfa/$${aws:username}",
    ]
  }

  statement {
    sid    = "IAMPasswordPolicy"
    effect = "Allow"
    actions = [
      "iam:GetAccountPasswordPolicy",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Deny"
    not_actions = [
      "iam:ResyncMFADevice",
      "iam:ListMFADevices",
      "iam:GetAccountPasswordPolicy",
      "iam:EnableMFADevice",
      "iam:CreateVirtualMFADevice",
      "iam:ChangePassword",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values = [
        false,
      ]
    }
  }
}


# ===============================================================================
# IAM for Lambda (Root Login Monitoring)
# ===============================================================================
resource "aws_iam_role" "root_login_monitoring" {
  name               = "${local.project}-${local.env}-iam-lambda-root-login-monitoring-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.root_login_monitoring_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-root-login-monitoring-role"
  }
}

data "aws_iam_policy_document" "root_login_monitoring_assume" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "root_login_monitoring" {
  name   = "${local.project}-${local.env}-iam-lambda-root-login-monitoring-policy"
  policy = data.aws_iam_policy_document.root_login_monitoring.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-root-login-monitoring-policy"
  }
}

data "aws_iam_policy_document" "root_login_monitoring" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.root_login_monitoring.arn,
      "${aws_cloudwatch_log_group.root_login_monitoring.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "root_login_monitoring" {
  role       = aws_iam_role.root_login_monitoring.name
  policy_arn = aws_iam_policy.root_login_monitoring.arn
}


# ===============================================================================
# IAM for Lambda (Lambda Error)
# ===============================================================================
resource "aws_iam_role" "lambda_error" {
  name               = "${local.project}-${local.env}-iam-lambda-error-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_error_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-error-role"
  }
}

data "aws_iam_policy_document" "lambda_error_assume" {
  statement {
    sid    = ""
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "lambda_error" {
  name   = "${local.project}-${local.env}-iam-lambda-error-policy"
  policy = data.aws_iam_policy_document.lambda_error.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-error-policy"
  }
}

data "aws_iam_policy_document" "lambda_error" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.project}-${local.env}-*:*",
    ]
  }
}

resource "aws_iam_policy_attachment" "lambda_error" {
  name = "${local.project}-${local.env}-iam-lambda-error-attachment"
  roles = [
    aws_iam_role.lambda_error.name,
  ]
  policy_arn = aws_iam_policy.lambda_error.arn
}


# ===============================================================================
# IAM for Chatbot
# ===============================================================================
resource "aws_iam_role" "chatbot" {
  name               = "${local.project}-${local.env}-iam-chatbot-general-role"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-general-role"
  }
}

data "aws_iam_policy_document" "chatbot_assume" {
  statement {
    sid    = "ChatbotAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "chatbot.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "chatbot" {
  name   = "${local.project}-${local.env}-iam-chatbot-general-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.chatbot.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-general-policy"
  }
}

data "aws_iam_policy_document" "chatbot" {
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
      "sns:Unsubscribe",
      "sns:ListTopics",
      "sns:ListSubscriptions",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/chatbot/*",
    ]
  }

  statement {
    sid    = "ChatbotAccess"
    effect = "Allow"
    actions = [
      "chatbot:CreateSlackChannelConfiguration",
      "chatbot:DeleteSlackWorkspaceAuthorization",
      "chatbot:DescribeSlackChannelConfigurations",
      "chatbot:DeleteSlackChannelConfiguration",
      "chatbot:CreateChimeWebhookConfiguration",
      "chatbot:DescribeChimeWebhookConfigurations",
      "chatbot:DeleteChimeWebhookConfiguration",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot.arn
}


# ===============================================================================
# IAM for Chatbot Guardrail
# ===============================================================================
resource "aws_iam_policy" "chatbot_guardrail" {
  name   = "${local.project}-${local.env}-iam-chatbot-guardrail-general-policy"
  policy = data.aws_iam_policy_document.chatbot_guardrail.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-guardrail-general-policy"
  }
}

data "aws_iam_policy_document" "chatbot_guardrail" {
  statement {
    sid    = "ChatbotAccess"
    effect = "Allow"
    actions = [
      "chatbot:DescribeSlackChannelConfigurations",
      "chatbot:DescribeChimeWebhookConfigurations",
    ]
    resources = [
      "*",
    ]
  }
}


# ===============================================================================
# AWS Config
# ===============================================================================
resource "aws_iam_role" "config_recorder" {
  name               = "${local.project}-${local.env}-iam-aws-config-recorder-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.config_recorder_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-aws-config-recorder-role"
  }
}

data "aws_iam_policy_document" "config_recorder_assume" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "config_recorder" {
  name   = "${local.project}-${local.env}-iam-aws-config-recorder-policy"
  policy = data.aws_iam_policy_document.config_recorder.json

  tags = {
    Name = "${local.project}-${local.env}-iam-aws-config-recorder-policy"
  }
}

data "aws_iam_policy_document" "config_recorder" {
  statement {
    sid    = "ResourceAccess"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "SNS:Publish",
    ]
    resources = [
      aws_s3_bucket.config_logs.arn,
      "${aws_s3_bucket.config_logs.arn}/*",
      aws_sns_topic.to_slack_general.arn,
    ]
  }

  statement {
    sid    = "CloudTrailAccess"
    effect = "Allow"
    actions = [
      "cloudtrail:Get*",
      "cloudtrail:Describe*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "config_recorder" {
  role       = aws_iam_role.config_recorder.name
  policy_arn = aws_iam_policy.config_recorder.arn
}

resource "aws_iam_role_policy_attachment" "config_recorder_to_AWSConfigRole" {
  role       = aws_iam_role.config_recorder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}
