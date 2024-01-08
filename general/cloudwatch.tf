# ===============================================================================
# CloudWatch Metrics for Lambda
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.project}-${local.env}-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.to_slack_general.arn,
  ]
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${local.project}-${local.env}-lambda-throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.to_slack_general.arn,
  ]
}

resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  alarm_name          = "${local.project}-${local.env}-lambda-concurrent-executions"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = data.aws_servicequotas_service_quota.lambda_concurrent_executions.value * 0.8
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.to_slack_general.arn,
  ]
}

data "aws_servicequotas_service_quota" "lambda_concurrent_executions" {
  quota_name   = "Concurrent executions"
  service_code = "lambda"
}


# ===============================================================================
# Login root monitoring
# ===============================================================================
resource "aws_cloudwatch_log_group" "root_login_monitoring" {
  name              = "/aws/lambda/${aws_lambda_function.root_login_monitoring.function_name}"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_subscription_filter" "root_login_monitoring_lambda" {
  name            = "root-login-monitoring-lambda"
  log_group_name  = aws_cloudwatch_log_group.cloudtrail.name
  filter_pattern  = "{ $.responseElements.ConsoleLogin = \"Success\" && $.userIdentity.type = \"Root\" }"
  destination_arn = aws_lambda_function.root_login_monitoring.arn
}


# ===============================================================================
# CloudTrail monitoring
# ===============================================================================
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "${local.project}-${local.env}-cloudtrail"
  retention_in_days = 365
}


# ===============================================================================
# Lambda errors
# ===============================================================================
resource "aws_cloudwatch_log_group" "lambda_errors" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_errors.function_name}"
  retention_in_days = 365
}
