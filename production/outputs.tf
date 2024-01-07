# ===============================================================================
# Outputs from Production
# ===============================================================================
output "s3_bucket_bastion_arn" {
  value = aws_s3_bucket.bastion.arn
}

output "lambda_log_error_alert_arn" {
  value = aws_lambda_function.lambda_log_error_alert.arn
}

output "sns_metric_alarm_arn" {
  value = aws_sns_topic.metric_alarm.arn
}
