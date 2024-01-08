resource "aws_cloudwatch_log_subscription_filter" "root_login_monitoring_lambda" {
  name            = "root-login-monitoring-lambda"
  log_group_name  = aws_cloudwatch_log_group.cloudtrail.name
  filter_pattern  = "{ $.responseElements.ConsoleLogin = \"Success\" && $.userIdentity.type = \"Root\" }"
  destination_arn = aws_lambda_function.root_login_monitoring.arn
}

