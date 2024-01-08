# ===============================================================================
# CloudTrail
# ===============================================================================
resource "aws_cloudtrail" "audit" {
  name                          = "${local.project}-${local.env}-cloudtrail-audit"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  tags = {
    Name = "${local.project}-${local.env}-cloudtrail-audit"
  }
}
