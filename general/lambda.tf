# ===============================================================================
# Lambda Function for Root Login
# ===============================================================================
resource "aws_lambda_function" "root_login_monitoring" {
  function_name    = "${local.project}-${local.env}-lambda-root-login-monitoring"
  role             = aws_iam_role.root_login_monitoring.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.root_login_monitoring.output_path
  source_code_hash = data.archive_file.root_login_monitoring.output_base64sha256
  runtime          = "python3.11"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      account_name = local.project
      hook_url     = var.root_hook_url
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lambda-root-login-monitoring"
  }
}

data "archive_file" "root_login_monitoring" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/root_login_monitoring"
  output_path = "${path.module}/artifacts/root_login_monitoring.zip"
}

resource "aws_lambda_permission" "invoke_from_cloudwatche_logs" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.root_login_monitoring.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
}


# ===============================================================================
# Lambda Function for Lambda Errors
# ===============================================================================
resource "aws_lambda_function" "lambda_errors" {
  function_name    = "${local.project}-${local.env}-lambda-errors"
  role             = aws_iam_role.lambda_error.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.lambda_errors.output_path
  source_code_hash = data.archive_file.lambda_errors.output_base64sha256
  runtime          = "python3.11"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      hook_url = var.root_hook_url
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lambda-errors"
  }
}

data "archive_file" "lambda_errors" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/lambda_errors"
  output_path = "${path.module}/artifacts/lambda_errors.zip"
}

resource "aws_lambda_permission" "lambda_errors" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_errors.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:aws/lambda/*"
}
