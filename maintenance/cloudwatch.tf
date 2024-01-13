# ===============================================================================
# CloudWatch Log group for SES
# ===============================================================================
resource "aws_cloudwatch_log_group" "bastion" {
  name              = "${local.project}-${local.env}-cw-bastion-cwlog"
  retention_in_days = local.retention_in_days

  tags = {
    Name = "${local.project}-${local.env}-cw-bastion-cwlog"
  }
}

resource "aws_cloudwatch_log_stream" "bastion" {
  name           = "${local.project}-${local.env}-cw-bastion-cwstream"
  log_group_name = aws_cloudwatch_log_group.bastion.name
}


# ===============================================================================
# CloudWatch Metrics for EC2 (Bastion)
# ===============================================================================
resource "aws_cloudwatch_metric_alarm" "bastion_cpu_high" {
  alarm_name          = "${local.project}-${local.env}-ec2-bastion-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    Instance = aws_instance.ec2_bastion.id
  }

  tags = {
    Name = "${local.project}-${local.env}-ec2-bastion-cpu-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "bastion_memory_high" {
  alarm_name          = "${local.project}-${local.env}-ec2-bastion-memory-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    Instance = aws_instance.ec2_bastion.id
  }

  tags = {
    Name = "${local.project}-${local.env}-ec2-bastion-memory-high-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_bastion_status_check_failed" {
  alarm_name          = "${local.project}-${local.env}-ec2-bastion-status-check-failed-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  dimensions = {
    Instance = aws_instance.ec2_bastion.id
  }

  tags = {
    Name = "${local.project}-${local.env}-ec2-bastion-status-check-failed-alarm"
  }
}
