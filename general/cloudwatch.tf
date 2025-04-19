# ===============================================================================
# CloudWatch Log group for Login root monitoring
# ===============================================================================
resource "aws_cloudwatch_log_group" "root_login_monitoring" {
  name              = "/aws/lambda/${aws_lambda_function.root_login_monitoring.function_name}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${aws_lambda_function.root_login_monitoring.function_name}-cwlog"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "root_login_monitoring_lambda" {
  name            = "${local.project}-${local.env}-cw-root-login-monitoring-lambda"
  log_group_name  = aws_cloudwatch_log_group.cloudtrail.name
  filter_pattern  = "{ $.responseElements.ConsoleLogin = \"Success\" && $.userIdentity.type = \"Root\" }"
  destination_arn = aws_lambda_function.root_login_monitoring.arn
}


# ===============================================================================
# CloudWatch Log group for Lambda errors
# ===============================================================================
resource "aws_cloudwatch_log_group" "lambda_errors" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_errors.function_name}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${aws_lambda_function.lambda_errors.function_name}-cwlog"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_errors" {
  name            = "${local.project}-${local.env}-cw-lambda-erros"
  log_group_name  = aws_cloudwatch_log_group.lambda_errors.name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_errors.arn
}


# ===============================================================================
# CloudWatch Log group for CloudTrail monitoring
# ===============================================================================
resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "${local.project}-${local.env}-cloudtrail-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cloudtrail-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "cloudtrail" {
  name           = "${local.project}-${local.env}-cw-cloudtrail-cwstream"
  log_group_name = aws_cloudwatch_log_group.cloudtrail.name
}


# ===============================================================================
# CloudWatch Log group for SNS
# ===============================================================================
resource "aws_cloudwatch_log_group" "sns" {
  name              = "${local.project}-${local.env}-sns-status-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-sns-status-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "sns" {
  name           = "${local.project}-${local.env}-cw-ses-cwstream"
  log_group_name = aws_cloudwatch_log_group.sns.name
}


# ===============================================================================
# CloudWatch Metrics for Lambda
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.project}-${local.env}-cw-lambda-errors-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  ok_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cw-lambda-errors-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${local.project}-${local.env}-cw-lambda-throttles-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  ok_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cw-lambda-throttles-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  alarm_name          = "${local.project}-${local.env}-cw-lambda-concurrent-executions-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = data.aws_servicequotas_service_quota.lambda_concurrent_executions.value * 0.8
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  ok_actions = [
    aws_sns_topic.to_slack_audit.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cw-lambda-concurrent-executions-alarm"
  }
}

data "aws_servicequotas_service_quota" "lambda_concurrent_executions" {
  quota_name   = "Concurrent executions"
  service_code = "lambda"
}
