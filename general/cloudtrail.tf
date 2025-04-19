# ===============================================================================
# CloudTrail
# ===============================================================================
resource "aws_cloudtrail" "audit" {
  name                          = "${local.project}-${local.env}-ct-audit"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  enable_logging                = true
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = false

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"
      values = [
        "${aws_s3_bucket.cloudtrail_logs.arn}/",
      ]
    }
  }

  depends_on = [
    aws_s3_bucket.cloudtrail_logs,
    aws_s3_bucket_policy.cloudtrail_logs,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ct-audit"
  }
}
