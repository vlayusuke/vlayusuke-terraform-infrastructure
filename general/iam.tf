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
