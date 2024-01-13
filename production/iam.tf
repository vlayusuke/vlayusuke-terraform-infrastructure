# ===============================================================================
# IAM OIDC Provider for GitHub
# ===============================================================================
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint,
  ]

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = {
    Name = "${local.project}-${local.env}-iam-oidc-provider-idp"
  }
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

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
        "repo:arsaga-partners/${local.project}-server:*",
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
    sid    = "GetAuthorizationToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "PushImageOnly"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:BatchGetImage",
      "ecr:PutImage",
    ]
    resources = [
      aws_ecr_repository.nginx_base.arn,
      aws_ecr_repository.app_base.arn,
      aws_ecr_repository.nginx.arn,
      aws_ecr_repository.app.arn,
    ]
  }

  statement {
    sid    = "RegisterTaskDefinition"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "events:PutTargets",
      "ecs:RunTask",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "UpdateService"
    effect = "Allow"
    actions = [
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:DescribeTasks",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:UpdateService",
    ]
    resources = [
      "*",
    ]
  }

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
    ]
  }

  statement {
    sid    = "IAMPassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.ecs_service.arn,
      aws_iam_role.ecs_task.arn,
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values = [
        "ecs-tasks.amazonaws.com",
        "ecs.amazonaws.com",
      ]
    }
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
# IAM for ECS Service
# ===============================================================================
resource "aws_iam_role" "ecs_service" {
  name               = "${local.project}-${local.env}-iam-ecs-service-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ecs-service-role"
  }
}

data "aws_iam_policy_document" "ecs_service_assume" {
  statement {
    sid    = "ECSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "ecs_service" {
  name   = "${local.project}-${local.env}-iam-ecs-service-policy"
  policy = data.aws_iam_policy_document.ecs_service.json

  tags = {
    Name = "${local.project}-${local.env}}-iam-ecs-service-policy"
  }
}

data "aws_iam_policy_document" "ecs_service" {
  statement {
    sid    = "PassRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "GetKeyAndParam"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "ssm:GetParameters",
    ]
    resources = [
      aws_kms_key.application.arn,
      aws_ssm_parameter.app_mysql_password.arn,
      aws_ssm_parameter.jwt_secret.arn,
      aws_ssm_parameter.app_key.arn,
      aws_ssm_parameter.aurora_writer_endpoint.arn,
      aws_ssm_parameter.aurora_reader_endpoint.arn,
      aws_ssm_parameter.ec_writer_endpoint.arn,
      aws_ssm_parameter.ec_reader_endpoint.arn,
    ]
  }
}

resource "aws_iam_policy_attachment" "ecs_service" {
  name = "${local.project}-${local.env}-iam-ecs-service-attachment"
  roles = [
    aws_iam_role.ecs_service.name,
  ]
  policy_arn = aws_iam_policy.ecs_service.arn
}

resource "aws_iam_role_policy_attachment" "policy_ecs_task_execution_role_policy_to_ecs_service_attachment" {
  role       = aws_iam_role.ecs_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ===============================================================================
# IAM for ECS Task
# ===============================================================================
resource "aws_iam_role" "ecs_task" {
  name               = "${local.project}-${local.env}-iam-ecs-task-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ecs-task-role"
  }
}

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    sid    = "ECSAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com",
        "ecs-tasks.amazonaws.com",
        "delivery.logs.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "ecs_task" {
  name   = "${local.project}-${local.env}-iam-ecs-task-policy"
  policy = data.aws_iam_policy_document.ecs_task.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ecs-task-policy"
  }
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    sid    = "ECSAccess"
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "ecs:RunTask",
      "ecs:ListTaskDefinitions",
      "ecs:DescribeServices",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::${local.project}-${local.env}-*",
    ]
  }

  statement {
    sid    = "SendMail"
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = [
      "arn:aws:ses:${local.region}:${data.aws_caller_identity.current.account_id}:identity/*",
      "arn:aws:ses:${local.region}:${data.aws_caller_identity.current.account_id}:configuration-set/${local.project}-${local.env}-event",
    ]
  }

  statement {
    sid    = "LogAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "LogDeliveryWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
    ]
  }

  statement {
    sid    = "PutLogDestination"
    effect = "Allow"
    actions = [
      "logs:PutDestination",
      "logs:PutDestinationPolicy",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*",
    ]
  }
}

resource "aws_iam_policy_attachment" "ecs_task" {
  name = "${local.project}-${local.env}-iam-ecs-task-attachment"
  roles = [
    aws_iam_role.ecs_task.name,
  ]
  policy_arn = aws_iam_policy.ecs_task.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_to_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.ecs_task.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


# ===============================================================================
# IAM for Lambda (CloudWatch Error Alert)
# ===============================================================================
resource "aws_iam_role" "lambda_cloudwatch" {
  name               = "${local.project}-${local.env}-iam-lambda-cw-logs-error-alert-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-cw-logs-error-alert-role"
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    sid    = "LambdaAssume"
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

resource "aws_iam_policy" "lambda_cloudwatch" {
  name   = "${local.project}-${local.env}-iam-lambda-cw-logs-error-alert-policy"
  policy = data.aws_iam_policy_document.lambda.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-cw-logs-error-alert-policy"
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "LogAccess"
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

  statement {
    sid    = "SNSPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.event_alarm.arn,
    ]
  }
}

resource "aws_iam_policy_attachment" "lambda" {
  name = "${local.project}-${local.env}-iam-lambda-cw-logs-error-alert-attachment"
  roles = [
    aws_iam_role.lambda_cloudwatch.name,
  ]
  policy_arn = aws_iam_policy.lambda_cloudwatch.arn
}


# ===============================================================================
# IAM for Lambda (RDS Control)
# ===============================================================================
resource "aws_iam_role" "rds_control" {
  name               = "${local.project}-${local.env}-iam-lambda-rds-control-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.rds_control_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-rds-control-role"
  }
}

data "aws_iam_policy_document" "rds_control_assume" {
  statement {
    sid    = "LambdaAssume"
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

resource "aws_iam_policy" "rds_control" {
  name   = "${local.project}-${local.env}-iam-lambda-rds-control-policy"
  policy = data.aws_iam_policy_document.rds_control.json

  tags = {
    Name = "${local.project}-${local.env}-iam-lambda-rds-control-policy"
  }
}

data "aws_iam_policy_document" "rds_control" {
  statement {
    sid    = "LogsAccess"
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

  statement {
    sid    = "RDSAccess"
    effect = "Allow"
    actions = [
      "rds:Describe*",
      "rds:StartDBCluster",
      "rds:StopDBCluster",
      "rds:ListTagsForResource",
    ]
    resources = [
      "arn:aws:rds:${local.region}:${data.aws_caller_identity.current.account_id}:cluster:*",
    ]
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
  }
}

resource "aws_iam_policy_attachment" "rds_control" {
  name = "${local.project}-${local.env}-iam-lambda-rds-control-attachment"
  roles = [
    aws_iam_role.rds_control.name,
  ]
  policy_arn = aws_iam_policy.rds_control.arn
}


# ===============================================================================
# IAM for Kinesis Data Firehose
# ===============================================================================
resource "aws_iam_role" "kinesis_data_firehose" {
  name               = "${local.project}-${local.env}-iam-kinesis-data-firehose-role"
  assume_role_policy = data.aws_iam_policy_document.kinesis_data_firehose_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-kinesis-data-firehose-role"
  }
}

data "aws_iam_policy_document" "kinesis_data_firehose_assume" {
  statement {
    sid    = "KDFAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "firehose.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "kinesis_data_firehose" {
  name   = "${local.project}-${local.env}-iam-kinesis-data-firehose-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.kinesis_data_firehose.json

  tags = {
    Name = "${local.project}-${local.env}-iam-kinesis-data-firehose-policy"
  }
}

data "aws_iam_policy_document" "kinesis_data_firehose" {
  statement {
    sid    = "S3Access"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.ses_event_log.arn,
      "${aws_s3_bucket.ses_event_log.arn}/*",
      aws_s3_bucket.aurora_logs.arn,
      "${aws_s3_bucket.aurora_logs.arn}/*",
    ]
  }

  statement {
    sid    = "PutLogEvents"
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_stream.ses.arn,
    ]
  }
}

resource "aws_iam_policy_attachment" "kinesis_data_firehose" {
  name = "${local.project}-${local.env}-iam-kinesis-data-firehose-attachment"
  roles = [
    aws_iam_role.kinesis_data_firehose.name,
  ]
  policy_arn = aws_iam_policy.kinesis_data_firehose.arn
}


# ===============================================================================
# IAM for SES
# ===============================================================================
resource "aws_iam_role" "ses" {
  name               = "${local.project}-${local.env}-iam-ses-role"
  assume_role_policy = data.aws_iam_policy_document.ses_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ses-role"
  }
}

data "aws_iam_policy_document" "ses_assume" {
  statement {
    sid    = "SESAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "ses.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "ses" {
  name   = "${local.project}-${local.env}-iam-ses-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.ses.json

  tags = {
    Name = "${local.project}-${local.env}-iam-ses-policy"
  }
}

data "aws_iam_policy_document" "ses" {
  statement {
    sid    = "KDFAccess"
    effect = "Allow"
    actions = [
      "firehose:*",
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.ses_event_log.arn,
    ]
  }
}

resource "aws_iam_policy_attachment" "ses" {
  name = "${local.project}-${local.env}-iam-ses-attachment"
  roles = [
    aws_iam_role.ses.name,
  ]
  policy_arn = aws_iam_policy.ses.arn
}


# ===============================================================================
# IAM for Inspector
# ===============================================================================
resource "aws_iam_role" "inspector" {
  name               = "${local.project}-${local.env}-iam-inspector-role"
  assume_role_policy = data.aws_iam_policy_document.inspector_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-inspector-role"
  }
}

data "aws_iam_policy_document" "inspector_assume" {
  statement {
    sid    = "EventAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "inspector" {
  name   = "${local.project}-${local.env}-iam-inspector-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.inspector.json

  tags = {
    Name = "${local.project}-${local.env}-iam-inspector-policy"
  }
}

data "aws_iam_policy_document" "inspector" {
  statement {
    sid    = "InspectorAccess"
    effect = "Allow"
    actions = [
      "inspector:StartAssessmentRun",
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
    ]
    resources = [
      aws_sns_topic.event_alarm.arn,
    ]
  }
}

resource "aws_iam_policy_attachment" "inspector" {
  name = "${local.project}-${local.env}-iam-inspector-attachment"
  roles = [
    aws_iam_role.inspector.name,
  ]
  policy_arn = aws_iam_policy.inspector.arn
}


# ===============================================================================
# IAM for Chatbot
# ===============================================================================
resource "aws_iam_role" "chatbot" {
  name               = "${local.project}-${local.env}-iam-chatbot-role"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-role"
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
  name   = "${local.project}-${local.env}-iam-chatbot-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.chatbot.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-policy"
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
      aws_sns_topic.metric_alarm.arn,
      aws_sns_topic.event_alarm.arn,
      aws_sns_topic.inspector_notification.arn,
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
  name   = "${local.project}-${local.env}-iam-chatbot-guardrail-policy"
  policy = data.aws_iam_policy_document.chatbot_guardrail.json

  tags = {
    Name = "${local.project}-${local.env}-iam-chatbot-guardrail-policy"
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
# IAM for EventBridge Scheduler
# ===============================================================================
resource "aws_iam_role" "event_bridge_scheduler" {
  name               = "${local.project}-${local.env}-iam-event-bridge-scheduler-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.event_bridge_scheduler_assume.json

  tags = {
    Name = "${local.project}-${local.env}-iam-event-bridge-scheduler-role"
  }
}

data "aws_iam_policy_document" "event_bridge_scheduler_assume" {
  statement {
    sid    = "SchedulerAssume"
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type = "Service"
      identifiers = [
        "scheduler.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "event_bridge_scheduler" {
  name   = "${local.project}-${local.env}-iam-event-bridge-scheduler-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.event_bridge_scheduler.json

  tags = {
    Name = "${local.project}-${local.env}-iam-event-bridge-scheduler-policy"
  }
}

data "aws_iam_policy_document" "event_bridge_scheduler" {
  statement {
    sid    = "ControlRDS"
    effect = "Allow"
    actions = [
      "rds:Describe*",
      "rds:StartDBCluster",
      "rds:StopDBCluster",
    ]
    resources = [
      "arn:aws:rds:${local.region}:${data.aws_caller_identity.current.account_id}:cluster:${local.project}-${local.env}-aurora-cluster"
    ]
  }
}

resource "aws_iam_policy_attachment" "event_bridge_scheduler" {
  name = "${local.project}-${local.env}-iam-event-bridge-scheduler-attachment"
  roles = [
    aws_iam_role.event_bridge_scheduler.name,
  ]
  policy_arn = aws_iam_policy.event_bridge_scheduler.arn
}
