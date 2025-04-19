# ================================================================================
# Local Values in production
# ================================================================================

# ================================================================================
# Environment
# ================================================================================
locals {
  env             = "prd"
  repository_name = "vlayusuke"
}


# ================================================================================
# Network
# ================================================================================
locals {
  vpc_cidr_block       = "172.20.0.0/16"
  default_gateway_cidr = "0.0.0.0/0"
}


# ================================================================================
# Aurora
# ================================================================================
locals {
  rds_max_connections = 512

  enabled_cloudwatch_logs_exports = toset([
    "audit",
    "error",
    "general",
    "slowquery",
  ])
}


# ================================================================================
# CloudWatch
# ================================================================================
locals {
  retention_in_days = 1827

  lambda_functions = toset([
    aws_lambda_function.rds_control.function_name,
    aws_lambda_function.lambda_log_error_alert.function_name,
  ])

  app_log_group = toset([
    "app-app",
    "cron",
    "queue",
    "migrate",
  ])

  nginx_log_group = toset([
    "app-nginx"
  ])

  aurora_log_types = {
    audit     = aws_kinesis_firehose_delivery_stream.aurora_logs_audit.arn
    error     = aws_kinesis_firehose_delivery_stream.aurora_logs_error.arn
    general   = aws_kinesis_firehose_delivery_stream.aurora_logs_general.arn
    slowquery = aws_kinesis_firehose_delivery_stream.aurora_logs_slowquery.arn
  }
}


# ================================================================================
# Lambda
# ================================================================================
locals {
  ssm_parameter_store_timeout_millis = 3000
}


# ================================================================================
# S3
# ================================================================================
locals {
  transition_days = 365
  expire_days     = 1827
}
