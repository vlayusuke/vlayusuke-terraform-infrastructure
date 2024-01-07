# ===============================================================================
# EventBridge Scheduler (RDS Control)
# ===============================================================================
resource "aws_scheduler_schedule_group" "rds_control" {
  name = "${local.project}-${local.env}-eb-scheduler-group-rds-control"

  tags = {
    Name = "${local.project}-${local.env}-eb-scheduler-group-rds-control"
  }
}

resource "aws_scheduler_schedule" "rds_control_start" {
  name       = "${local.project}-${local.env}-eb-scheduler-rds-control-start"
  group_name = aws_scheduler_schedule_group.rds_control.name
  state      = "DISABLED"

  schedule_expression          = "cron(0 9 ? * * *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster"
    role_arn = aws_iam_role.event_bridge_scheduler.arn

    input = jsonencode({
      "DbClusterIdentifier" : aws_rds_cluster.aurora.cluster_identifier
    })
  }
}

resource "aws_scheduler_schedule" "rds_control_stop" {
  name       = "${local.project}-${local.env}-eb-scheduler-rds-control-stop"
  group_name = aws_scheduler_schedule_group.rds_control.name
  state      = "DISABLED"

  schedule_expression          = "cron(0 21 ? * * *)"
  schedule_expression_timezone = "Asia/Tokyo"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster"
    role_arn = aws_iam_role.event_bridge_scheduler.arn

    input = jsonencode({
      "DbClusterIdentifier" : aws_rds_cluster.aurora.cluster_identifier
    })
  }
}


# ===============================================================================
# EventBridge (ECR Image Scan Notification)
# ===============================================================================
resource "aws_cloudwatch_event_rule" "ecr_image_scan" {
  name           = "${local.project}-${local.env}-eb-ecr-image-scan"
  description    = "ECR Image Scan Notification"
  event_bus_name = "default"

  event_pattern = jsonencode({
    "source" : [
      "aws.ecr"
    ],
    "detail-type" : [
      "ECR Image Scan"
    ]
  })

  tags = {
    Name = "${local.project}-${local.env}-eb-ecr-image-scan"
  }
}

resource "aws_cloudwatch_event_target" "ecr_image_scan" {
  rule      = aws_cloudwatch_event_rule.ecr_image_scan.name
  target_id = aws_sns_topic.to_slack.name
  arn       = aws_sns_topic.to_slack.arn
}
