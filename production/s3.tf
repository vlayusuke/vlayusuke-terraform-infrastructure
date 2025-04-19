data "aws_elb_service_account" "alb_logs" {}


# ===============================================================================
# S3 Bucket for Assets
# ===============================================================================
resource "aws_s3_bucket" "assets" {
  bucket = "${local.project}-${local.env}-s3-assets-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-assets-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "assets" {
  bucket = aws_s3_bucket.assets.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.assets,
  ]
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    id     = "delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.assets,
  ]
}

resource "aws_s3_bucket_cors_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "PUT",
      "POST",
      "GET",
    ]
    allowed_origins = [
      "https://${local.domain}",
    ]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_policy" "assets_oac" {
  bucket = aws_s3_bucket.assets.id
  policy = data.aws_iam_policy_document.assets_oac.json
}

data "aws_iam_policy_document" "assets_oac" {
  statement {
    sid    = "S3List"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.assets.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.production.arn,
      ]
    }
  }

  statement {
    sid    = "S3Get"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.assets.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.production.arn,
      ]
    }
  }
}


# ===============================================================================
# S3 Bucket for Uploads
# ===============================================================================
resource "aws_s3_bucket" "uploads" {
  bucket = "${local.project}-${local.env}-s3-uploads-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-uploads-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.uploads,
  ]
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    id     = "transition-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.expire_days
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = local.expire_days
      storage_class   = "GLACIER"
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.uploads,
  ]
}

resource "aws_s3_bucket_cors_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "PUT",
      "POST",
      "GET",
    ]
    allowed_origins = [
      "https://${local.domain}",
    ]
    max_age_seconds = 3600
  }
}

resource "aws_s3_bucket_policy" "uploads_oac" {
  bucket = aws_s3_bucket.uploads.id
  policy = data.aws_iam_policy_document.uploads_oac.json
}

data "aws_iam_policy_document" "uploads_oac" {
  statement {
    sid    = "S3List"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.uploads.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.production.arn,
      ]
    }
  }

  statement {
    sid    = "S3Get"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.uploads.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        aws_cloudfront_distribution.production.arn
      ]
    }
  }
}


# ===============================================================================
# S3 Bucket for ALB logs
# ===============================================================================
resource "aws_s3_bucket" "alb_logs" {
  bucket = "${local.project}-${local.env}-s3-alb-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-alb-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.alb_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.alb_logs.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    id     = "transition-and-delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_transition {
      noncurrent_days = local.transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.alb_logs,
  ]
}

data "aws_iam_policy_document" "alb_logs" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_elb_service_account.alb_logs.id}:root",
      ]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.alb_logs.arn}/*",
    ]
  }

  statement {
    principals {
      type = "Service"
      identifiers = [
        "delivery.logs.amazonaws.com",
      ]
    }
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.alb_logs.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}


# ===============================================================================
# S3 Bucket for VPC flow log
# ===============================================================================
resource "aws_s3_bucket" "vpc_flow_log" {
  bucket = "${local.project}-${local.env}-s3-vpc-flow-log-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-vpc-flow-log-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.vpc_flow_log,
  ]
}

resource "aws_s3_bucket_public_access_block" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_log" {
  bucket = aws_s3_bucket.vpc_flow_log.id

  rule {
    id     = "transition-and-delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_transition {
      noncurrent_days = local.transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.vpc_flow_log,
  ]
}


# ===============================================================================
# S3 Bucket for SES event log
# ===============================================================================
resource "aws_s3_bucket" "ses_event_log" {
  bucket = "${local.project}-${local.env}-s3-ses-event-log-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-ses-event-log-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "ses_event_log" {
  bucket = aws_s3_bucket.ses_event_log.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "ses_event_log" {
  bucket = aws_s3_bucket.ses_event_log.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.ses_event_log,
  ]
}

resource "aws_s3_bucket_public_access_block" "ses_event_log" {
  bucket = aws_s3_bucket.ses_event_log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ses_event_log" {
  bucket = aws_s3_bucket.ses_event_log.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "ses_event_log" {
  bucket = aws_s3_bucket.ses_event_log.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ses_event_log" {
  bucket = aws_s3_bucket.ses_event_log.id

  rule {
    id     = "transition-and-delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_transition {
      noncurrent_days = local.transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.ses_event_log,
  ]
}


# ===============================================================================
# S3 Bucket for Aurora logs
# ===============================================================================
resource "aws_s3_bucket" "aurora_logs" {
  bucket = "${local.project}-${local.env}-s3-aurora-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-aurora-logs-bucket"
  }
}

resource "aws_s3_object" "prefix_audit" {
  bucket = aws_s3_bucket.aurora_logs.bucket
  key    = "audit/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-audit"
  }
}

resource "aws_s3_object" "prefix_error" {
  bucket = aws_s3_bucket.aurora_logs.bucket
  key    = "error/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-error"
  }
}

resource "aws_s3_object" "prefix_general" {
  bucket = aws_s3_bucket.aurora_logs.bucket
  key    = "general/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-general"
  }
}

resource "aws_s3_object" "prefix_slowquery" {
  bucket = aws_s3_bucket.aurora_logs.bucket
  key    = "slowquery/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-slowquery"
  }
}

resource "aws_s3_bucket_ownership_controls" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.aurora_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "aurora_logs" {
  bucket = aws_s3_bucket.aurora_logs.id

  rule {
    id     = "transition-and-delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_transition {
      noncurrent_days = local.transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.aurora_logs,
  ]
}


# ===============================================================================
# S3 Bucket for ECS logs
# ===============================================================================
resource "aws_s3_bucket" "ecs_logs" {
  bucket = "${local.project}-${local.env}-s3-ecs-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-ecs-logs-bucket"
  }
}

resource "aws_s3_object" "prefix_app_app" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "app-app/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-app-app"
  }
}

resource "aws_s3_object" "prefix_app_nginx" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "app-nginx/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-app-nginx"
  }
}

resource "aws_s3_object" "prefix_cron" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "cron/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-cron"
  }
}

resource "aws_s3_object" "prefix_migrate" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "migrate/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-migrate"
  }
}

resource "aws_s3_object" "prefix_queue" {
  bucket = aws_s3_bucket.ecs_logs.bucket
  key    = "queue/"
  acl    = "private"

  tags = {
    Name = "${local.project}-${local.env}-s3-prefix-queue"
  }
}

resource "aws_s3_bucket_ownership_controls" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.ecs_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ecs_logs" {
  bucket = aws_s3_bucket.ecs_logs.id

  rule {
    id     = "transition-and-delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_transition {
      noncurrent_days = local.transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.ecs_logs,
  ]
}


# ===============================================================================
# S3 Bucket for CloudFront logs
# ===============================================================================
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${local.project}-${local.env}-s3-cloudfront-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-cloudfront-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.cloudfront_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  rule {
    id     = "transition-and-delete-object"
    status = "Enabled"

    filter {
      object_size_greater_than = 0
    }

    transition {
      days          = local.transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expire_days
    }

    noncurrent_version_transition {
      noncurrent_days = local.transition_days
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = local.expire_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.cloudfront_logs,
  ]
}


# ===============================================================================
# S3 Bucket for S3 Access Logs
# ===============================================================================
resource "aws_s3_bucket" "access_logs" {
  bucket = "${local.project}-${local.env}-s3-access-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-access-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.access_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  versioning_configuration {
    status = "Disabled"
  }
}


# ===============================================================================
# S3 Bucket for S3 WAF Logs
# ===============================================================================
resource "aws_s3_bucket" "waf_logs" {
  bucket = "aws-waf-logs-${local.project}-${local.env}-s3-waf-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-waf-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.waf_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id
  versioning_configuration {
    status = "Disabled"
  }
}
