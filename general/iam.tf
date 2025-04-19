# ===============================================================================
# IAM for Deployment
# ===============================================================================
resource "aws_iam_role" "github_actions_deploy" {
  name               = "${local.project}-${local.env}-iam-github-actions-deploy-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.github_actions_deploy_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-deploy-role"
  }
}

data "aws_iam_policy_document" "github_actions_deploy_assume" {
  statement {
    sid    = "OIDCFederate"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.repository_name}/*",
      ]
    }
  }
}

resource "aws_iam_policy" "github_actions_deploy" {
  name   = "${local.project}-${local.env}-iam-github-actions-deploy-policy"
  policy = data.aws_iam_policy_document.github_actions_deploy.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-deploy-policy"
  }
}

data "aws_iam_policy_document" "github_actions_deploy" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${local.project}-${local.env}-*",
      "arn:aws:s3:::${local.project}-${local.env}-*/*",
      "arn:aws:s3:::terraform-*",
    ]
  }
}

resource "aws_iam_policy_attachment" "github_actions_deploy" {
  name = "${local.project}-${local.env}-iam-github-actions-deploy-attachment"
  roles = [
    aws_iam_role.github_actions_deploy.name,
  ]
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}


# ===============================================================================
# IAM for Source Code Backup
# ===============================================================================
resource "aws_iam_role" "github_actions_backup" {
  name               = "${local.project}-${local.env}-iam-github-actions-backup-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.github_actions_backup_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-backup-role"
  }
}

data "aws_iam_policy_document" "github_actions_backup_assume" {
  statement {
    sid    = "OIDCFederate"
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.repository_name}/*",
      ]
    }
  }
}

resource "aws_iam_policy" "github_actions_backup" {
  name   = "${local.project}-${local.env}-iam-github-actions-backup-policy"
  policy = data.aws_iam_policy_document.github_actions_backup.json

  tags = {
    Name = "${local.project}-${local.env}-iam-github-actions-backup-policy"
  }
}

data "aws_iam_policy_document" "github_actions_backup" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${local.project}-${local.env}-*",
      "arn:aws:s3:::${local.project}-${local.env}-*/*",
      "arn:aws:s3:::mcury-*",
    ]
  }
}

resource "aws_iam_policy_attachment" "github_actions_backup" {
  name = "${local.project}-${local.env}-iam-github-actions-backup-attachment"
  roles = [
    aws_iam_role.github_actions_backup.name,
  ]
  policy_arn = aws_iam_policy.github_actions_backup.arn
}


# ===============================================================================
# IAM for Lambda (Root Login Monitoring)
# ===============================================================================
resource "aws_iam_role" "lambda_root_login_monitoring" {
  name               = "${local.project}-${local.env}-iam-lambda-root-login-monitoring-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_root_login_monitoring_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-root-login-monitoring-role"
  }
}

data "aws_iam_policy_document" "lambda_root_login_monitoring_assume" {
  statement {
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

resource "aws_iam_policy" "lambda_root_login_monitoring" {
  name   = "${local.project}-${local.env}-iam-lambda-root-login-monitoring-policy"
  policy = data.aws_iam_policy_document.lambda_root_login_monitoring.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-root-login-monitoring-policy"
  }
}

data "aws_iam_policy_document" "lambda_root_login_monitoring" {
  statement {
    sid    = "GenarateLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:*",
    ]
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
  }
}

resource "aws_iam_role_policy_attachment" "lambda_root_login_monitoring" {
  role       = aws_iam_role.lambda_root_login_monitoring.name
  policy_arn = aws_iam_policy.lambda_root_login_monitoring.arn
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
    sid    = "GenarateLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.project}-${local.env}-*:*",
    ]
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
  }
}

resource "aws_iam_role_policy_attachment" "lambda_error" {
  role       = aws_iam_role.lambda_error.name
  policy_arn = aws_iam_policy.lambda_error.arn
}



# ===============================================================================
# IAM for Chatbot
# ===============================================================================
resource "aws_iam_role" "chatbot" {
  name               = "${local.project}-${local.env}-iam-chatbot-audit-role"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-audit-role"
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
  name   = "${local.project}-${local.env}-iam-chatbot-audit-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.chatbot.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-audit-policy"
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
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.to_slack_audit.arn,
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

# resource "aws_iam_role_policy_attachment" "chatbot" {
#   role       = aws_iam_role.chatbot.name
#   policy_arn = aws_iam_policy.chatbot.arn
# }

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"
}


# ===============================================================================
# IAM for Chatbot Guardrail
# ===============================================================================
resource "aws_iam_policy" "chatbot_guardrail" {
  name   = "${local.project}-${local.env}-iam-chatbot-guardrail-audit-policy"
  policy = data.aws_iam_policy_document.chatbot_guardrail.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-guardrail-audit-policy"
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
# IAM for AWS Config
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
    ]
    resources = [
      aws_s3_bucket.config_logs.arn,
      "${aws_s3_bucket.config_logs.arn}/*",
    ]
  }

  statement {
    sid    = "ConfigRecorder"
    effect = "Allow"
    actions = [
      "config:DescribeConfigurationRecorders",
      "config:DeleteConfigurationRecorder",
    ]
    resources = [
      "*",
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

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.to_slack_audit.arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "config_recorder" {
  role       = aws_iam_role.config_recorder.name
  policy_arn = aws_iam_policy.config_recorder.arn
}

resource "aws_iam_role_policy_attachment" "config_recorder_to_AWS_ConfigRole" {
  role       = aws_iam_role.config_recorder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}


# ===============================================================================
# IAM for SNS
# ===============================================================================
resource "aws_iam_role" "sns" {
  name               = "${local.project}-${local.env}-iam-sns-role"
  assume_role_policy = data.aws_iam_policy_document.sns_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-sns-role"
  }
}

data "aws_iam_policy_document" "sns_assume" {
  statement {
    sid    = "SNSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "sns" {
  name   = "${local.project}-${local.env}-iam-sns-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.sns.json

  tags = {
    Name = "${local.project}-${local.env}-iam-sns-policy"
  }
}

data "aws_iam_policy_document" "sns" {
  statement {
    sid    = "DescribeLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.sns.arn
    ]
  }

  statement {
    sid    = "SNSSubscribe"
    effect = "Allow"
    actions = [
      "sns:Subscribe",
    ]
    resources = [
      aws_sns_topic.to_slack_audit.arn,
    ]
  }
}
