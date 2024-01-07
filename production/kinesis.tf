# ===============================================================================
# Kinesis Data Firehose Stream (SES event log)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "ses_event_log" {
  name        = "${local.project}-${local.env}-ses-event-log-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_data_firehose.arn
    bucket_arn         = aws_s3_bucket.ses_event_log.arn
    buffering_size     = 64
    buffering_interval = 300
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.ses.name
      log_stream_name = aws_cloudwatch_log_stream.ses.name
    }
  }

  tags = {
    Name = "${local.project}-${local.env}-ses-event-log-to-s3"
  }
}


# ===============================================================================
# Kinesis Data Firehose Stream (Aurora log)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "aurora_logs" {
  name        = element(local.kinesis_name_aurora, count.index)
  destination = "extended_s3"
  count       = length(local.log_group_name_aurora)

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = element(local.s3_prefix_aurora, count.index)
    compression_format = "GZIP"
  }

  tags = {
    Name = element(local.kinesis_name_aurora, count.index)
  }
}


# ===============================================================================
# Kinesis Data Firehose Stream (ECS log)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "ecs_logs" {
  name        = element(local.kinesis_name_ecs, count.index)
  destination = "extended_s3"
  count       = length(local.log_group_name_ecs)

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_data_firehose.arn
    bucket_arn         = aws_s3_bucket.ecs_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = element(local.s3_prefix_ecs, count.index)
    compression_format = "GZIP"
  }

  tags = {
    Name = element(local.kinesis_name_ecs, count.index)
  }
}
