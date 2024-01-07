# ===============================================================================
# Local Value in Production
# ===============================================================================


# ===============================================================================
# Environment
# ===============================================================================
locals {
  env = "prd"
}


# ===============================================================================
# Network
# ===============================================================================
locals {
  vpc_cidr_block = "172.20.0.0/16"
}


# ===============================================================================
# Aurora
# ===============================================================================
locals {
  rds_max_connections = 512
  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery",
  ]
}


# ===============================================================================
# CloudWatch
# ===============================================================================
locals {
  retention_in_days = 1827
  lambda_functions = toset([
    aws_lambda_function.rds_control.function_name,
    aws_lambda_function.lambda_log_error_alert.function_name,
  ])
  app_log_group = [
    "app-app",
    "cron",
    "queue",
    "migrate",
  ]
  nginx_log_group = [
    "app-nginx",
  ]
}


# ===============================================================================
# Kinesis Data Firehose
# ===============================================================================
locals {
  log_group_name_aurora = [
    "/aws/rds/cluster/${local.project}-${local.env}-aurora-cluster/audit",
    "/aws/rds/cluster/${local.project}-${local.env}-aurora-cluster/error",
    "/aws/rds/cluster/${local.project}-${local.env}-aurora-cluster/general",
    "/aws/rds/cluster/${local.project}-${local.env}-aurora-cluster/slowquery",
  ]

  s3_prefix_aurora = [
    "audit",
    "error",
    "general",
    "slowquery",
  ]

  kinesis_name_aurora = [
    "${local.project}-${local.env}-aurora-log-audit-to-s3",
    "${local.project}-${local.env}-aurora-log-error-to-s3",
    "${local.project}-${local.env}-aurora-log-general-to-s3",
    "${local.project}-${local.env}-aurora-log-slowquery-to-s3",
  ]

  log_group_name_ecs = [
    "${local.project}-${local.env}-cw-app-app-cwlog",
    "${local.project}-${local.env}-cw-app-nginx-cwlog",
    "${local.project}-${local.env}-cw-batch-cwlog",
    "${local.project}-${local.env}-cw-cron-cwlog",
    "${local.project}-${local.env}-cw-migrate-cwlog",
    "${local.project}-${local.env}-cw-queue-cwlog",
  ]

  s3_prefix_ecs = [
    "app-app",
    "app-nginx",
    "batch",
    "cron",
    "migrate",
    "queue",
  ]

  kinesis_name_ecs = [
    "${local.project}-${local.env}-ecs-log-app-app-to-s3",
    "${local.project}-${local.env}-ecs-log-app-nginx-to-s3",
    "${local.project}-${local.env}-ecs-log-batch-to-s3",
    "${local.project}-${local.env}-ecs-log-cron-to-s3",
    "${local.project}-${local.env}-ecs-log-migrate-to-s3",
    "${local.project}-${local.env}-ecs-log-queue-to-s3",
  ]
}


# ===============================================================================
# Lambda
# ===============================================================================
locals {
  ssm_parameter_store_timeout_millis = 3000
}
