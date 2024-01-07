# ===============================================================================
# Lambda Function for CloudWatch log error alert
# ===============================================================================
resource "aws_lambda_function" "lambda_log_error_alert" {
  function_name    = "${local.project}-${local.env}-lambda-cloudwatch-logs-error-alert"
  role             = aws_iam_role.lambda_cloudwatch.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.log_error_alert.output_path
  source_code_hash = data.archive_file.log_error_alert.output_base64sha256
  runtime          = "python3.11"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  environment {
    variables = {
      hook_url = var.hook_url_app
    }
  }

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lambda-cloudwatch-logs-error-alert"
  }
}

data "archive_file" "log_error_alert" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/log_error_alert"
  output_path = "${path.module}/artifacts/log_error_alert.zip"
}

resource "aws_lambda_permission" "lambda_cloudwatch_app" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_log_error_alert.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
}


# ===============================================================================
# Lambda Function for RDS Control
# ===============================================================================
resource "aws_lambda_function" "rds_control" {
  function_name    = "${local.project}-${local.env}-lambda-rds-control"
  role             = aws_iam_role.rds_control.arn
  handler          = "lambda_function.lambda_handler"
  filename         = data.archive_file.rds_control.output_path
  source_code_hash = data.archive_file.rds_control.output_base64sha256
  runtime          = "python3.11"
  timeout          = 10
  memory_size      = 128

  architectures = [
    "arm64",
  ]

  lifecycle {
    ignore_changes = [
      source_code_hash,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-lambda-rds-control"
  }
}

data "archive_file" "rds_control" {
  type        = "zip"
  source_dir  = "${path.cwd}/files/lambda/rds_control"
  output_path = "${path.module}/artifacts/rds_control.zip"
}

resource "aws_lambda_function_event_invoke_config" "rds_control" {
  function_name = aws_lambda_function.rds_control.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.event_alarm.arn
    }

    on_success {
      destination = aws_sns_topic.event_alarm.arn
    }
  }
}

resource "aws_lambda_permission" "rds_control" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rds_control.function_name
  principal     = "logs.${local.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
}
