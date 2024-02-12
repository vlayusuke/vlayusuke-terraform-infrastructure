# ===============================================================================
# CloudWatch Log group for ECS
# ===============================================================================
resource "aws_cloudwatch_log_group" "app" {
  for_each          = local.app_log_group
  name              = "${local.project}-${local.env}-cw-${each.key}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cw-${each.key}-cwlog"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "app_to_lambda" {
  for_each        = local.app_log_group
  name            = aws_lambda_function.lambda_log_error_alert.function_name
  log_group_name  = "${local.project}-${local.env}-cw-${each.key}-cwlog"
  filter_pattern  = "{ $.level_name = \"ERROR\" || $.level_name = \"CRITICAL\" || $.level_name = \"ALERT\" || $.level_name = \"EMERGENCY\" }"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}

resource "aws_cloudwatch_log_group" "nginx" {
  for_each          = local.nginx_log_group
  name              = "${local.project}-${local.env}-cw-${each.key}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cw-${each.key}-cwlog"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "nginx_to_lambda" {
  for_each        = local.nginx_log_group
  name            = aws_lambda_function.lambda_log_error_alert.function_name
  log_group_name  = "${local.project}-${local.env}-cw-${each.key}-cwlog"
  filter_pattern  = "{ $.status = \"5*\" || $.request_time >= 3.000 }"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}


# ===============================================================================
# CloudWatch Log group for RDS
# ===============================================================================
resource "aws_cloudwatch_log_group" "rds" {
  for_each          = local.enabled_cloudwatch_logs_exports
  name              = "/aws/rds/cluster/${aws_rds_cluster.aurora.cluster_identifier}/${each.key}"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/rds/cluster/${aws_rds_cluster.aurora.cluster_identifier}/${each.key}"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "rds" {
  for_each        = local.enabled_cloudwatch_logs_exports
  name            = aws_lambda_function.lambda_log_error_alert.function_name
  log_group_name  = "/aws/rds/cluster/${aws_rds_cluster.aurora.cluster_identifier}/${each.key}"
  filter_pattern  = "?Warning ?Error"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}


# ===============================================================================
# CloudWatch Log group for Lambda Functions
# ===============================================================================
resource "aws_cloudwatch_log_group" "lambda_functions" {
  for_each          = local.lambda_functions
  name              = "/aws/lambda/${each.key}-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "/aws/lambda/${each.key}-cwlog"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_functions" {
  for_each        = local.lambda_functions
  name            = aws_lambda_function.lambda_log_error_alert.function_name
  log_group_name  = aws_cloudwatch_log_group.lambda_functions[each.key].name
  filter_pattern  = "ERROR"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}


# ===============================================================================
# CloudWatch Log group for SES
# ===============================================================================
resource "aws_cloudwatch_log_group" "ses" {
  name              = "${local.project}-${local.env}-cw-ses-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cw-ses-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "ses" {
  name           = "${local.project}-${local.env}-cw-ses-cwstream"
  log_group_name = aws_cloudwatch_log_group.ses.name
}

resource "aws_cloudwatch_log_subscription_filter" "ses" {
  name            = aws_lambda_function.lambda_log_error_alert.function_name
  log_group_name  = aws_cloudwatch_log_group.ses.name
  filter_pattern  = "bounce"
  destination_arn = aws_lambda_function.lambda_log_error_alert.arn
}


# ===============================================================================
# CloudWatch Metrics for ECS (app)
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-app-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.app_scale_out.arn,
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-app-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "app_cpu_low" {
  alarm_name          = "${local.project}-${local.env}-app-cpu-low-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 10
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Maximum"
  threshold           = 15
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = 10

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.app_scale_in.arn,
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-app-cpu-low-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "app_memory_high" {
  alarm_name          = "${local.project}-${local.env}-app-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  alarm_actions = [
    aws_appautoscaling_policy.app_scale_out.arn,
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-app-memory-high-alarm"
  }
}


# ===============================================================================
# CloudWatch Metrics for ECS (cron)
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "cron_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-cron-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.cron.name
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cron-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "cron_memory_high" {
  alarm_name          = "${local.project}-${local.env}-cron-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.cron.name
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-cron-memory-high-alarm"
  }
}


# ===============================================================================
# CloudWatch Metrics for ECS (queue)
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "queue_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-queue-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.queue.name
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-queue-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "queue_memory_high" {
  alarm_name          = "${local.project}-${local.env}-queue-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.queue.name
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-queue-memory-high-alarm"
  }
}


# ===============================================================================
# CloudWatch Metrics for ALB
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "alb_healthy_host" {
  alarm_name          = "${local.project}-${local.env}-alb-healthy-host-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Minimum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn
    TargetGroup  = aws_lb_target_group.alb_external_tg.arn
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-alb-healthy-host-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_un_healthy_host" {
  alarm_name          = "${local.project}-${local.env}-alb-un-healthy-host-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn
    TargetGroup  = aws_lb_target_group.alb_external_tg.arn
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-alb-un-healthy-host-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_rejected_connection" {
  alarm_name          = "${local.project}-${local.env}-alb-rejected-connection-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RejectedConnectionCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn
    TargetGroup  = aws_lb_target_group.alb_external_tg.arn
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-alb-rejected-connection-alarm"
  }
}


# ===============================================================================
# CloudWatch Metrics for RDS
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-rds-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-rds-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_memory_high" {
  alarm_name          = "${local.project}-${local.env}-rds-memory-high-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Minimum"
  threshold           = 256000000
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-rds-memory-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "${local.project}-${local.env}-rds-connections-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = floor(local.rds_max_connections * 0.8)
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora.id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-rds-connections-high-alarm"
  }
}


# ===============================================================================
# CloudWatch Metrics for ElastiCache
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "ec_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-ec-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.redis.replication_group_id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ec-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec_memory_high" {
  alarm_name          = "${local.project}-${local.env}-ec-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseMemoryUsagePercentage"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.redis.replication_group_id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ec-memory-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec_swap_high" {
  alarm_name          = "${local.project}-${local.env}-ec-swap-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "SwapUsage"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Maximum"
  threshold           = 50000000
  treat_missing_data  = "notBreaching"

  dimensions = {
    CacheClusterId = aws_elasticache_replication_group.redis.replication_group_id
  }

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ec-swap-high-alarm"
  }
}


# ===============================================================================
# CloudWatch Metrics for SES
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "ses_complaint_rate" {
  alarm_name          = "${local.project}-${local.env}-ses-complaint-rate-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Reputation.ComplaintRate"
  namespace           = "AWS/SES"
  period              = 60
  statistic           = "Minimum"
  threshold           = 0.001
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ses-complaint-rate-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ses_bounce_rate" {
  alarm_name          = "${local.project}-${local.env}-ses-bounce-rate-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Reputation.BounceRate"
  namespace           = "AWS/SES"
  period              = 60
  statistic           = "Minimum"
  threshold           = 0.001
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ses-bounce-rate-alarm"
  }
}


# ===============================================================================
# CloudWatch Metrics for Lambda
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${local.project}-${local.env}-lambda-errors-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-lambda-errors-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${local.project}-${local.env}-lambda-throttles-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-lambda-throttles-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  alarm_name          = "${local.project}-${local.env}-lambda-concurrent-executions-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConcurrentExecutions"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Maximum"
  threshold           = data.aws_servicequotas_service_quota.lambda_concurrent_executions.value * 0.8
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.metric_alarm.arn,
  ]

  tags = {
    Name = "${local.project}-${local.env}-lambda-concurrent-executions-alarm"
  }
}

data "aws_servicequotas_service_quota" "lambda_concurrent_executions" {
  quota_name   = "Concurrent executions"
  service_code = "lambda"
}
