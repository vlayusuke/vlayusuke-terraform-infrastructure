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

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  tags = {
    Name = "${local.project}-${local.env}-ses-event-log-to-s3"
  }
}


# ===============================================================================
# Kinesis Data Firehose Stream (Aurora log)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "aurora_logs_audit" {
  name        = "${local.project}-${local.env}-ks-aurora-log-audit-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "audit/"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  tags = {
    Name = "${local.project}-${local.env}-ks-aurora-log-audit-to-s3"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "aurora_logs_error" {
  name        = "${local.project}-${local.env}-ks-aurora-log-error-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "error/"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  tags = {
    Name = "${local.project}-${local.env}-ks-aurora-log-error-to-s3"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "aurora_logs_general" {
  name        = "${local.project}-${local.env}-ks-aurora-log-general-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "general/"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  tags = {
    Name = "${local.project}-${local.env}-ks-aurora-log-general-to-s3"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "aurora_logs_slowquery" {
  name        = "${local.project}-${local.env}-ks-aurora-log-slowquery-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_data_firehose.arn
    bucket_arn         = aws_s3_bucket.aurora_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "slowquery/"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  tags = {
    Name = "${local.project}-${local.env}-ks-aurora-log-slowquery-to-s3"
  }
}


# ===============================================================================
# Kinesis Data Firehose Stream (ECS log App)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "ecs_logs_app" {
  for_each    = local.app_log_group
  name        = "${local.project}-${local.env}-ecs-log-${each.key}-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_data_firehose.arn
    bucket_arn         = aws_s3_bucket.ecs_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${each.key}/"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-log-${each.key}-to-s3"
  }
}


# ===============================================================================
# Kinesis Data Firehose Stream (ECS log NginX)
# ===============================================================================
resource "aws_kinesis_firehose_delivery_stream" "ecs_logs_nginx" {
  for_each    = local.nginx_log_group
  name        = "${local.project}-${local.env}-ecs-log-${each.key}-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.kinesis_data_firehose.arn
    bucket_arn         = aws_s3_bucket.ecs_logs.arn
    buffering_size     = 64
    buffering_interval = 300
    prefix             = "${each.key}/"
    compression_format = "GZIP"
  }

  server_side_encryption {
    enabled  = true
    key_type = "AWS_OWNED_CMK"
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-log-${each.key}-to-s3"
  }
}
