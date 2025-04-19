data "aws_partition" "current" {}


# ===============================================================================
# S3 Bucket for CloudTrail
# ===============================================================================
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "${local.project}-${local.env}-s3-cloudtrail-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-cloudtrail-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.cloudtrail_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

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
    aws_s3_bucket_versioning.cloudtrail_logs,
  ]
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_logs.json
}

data "aws_iam_policy_document" "cloudtrail_logs" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [
      aws_s3_bucket.cloudtrail_logs.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]

    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }

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
# S3 Bucket for Config
# ===============================================================================
resource "aws_s3_bucket" "config_logs" {
  bucket = "${local.project}-${local.env}-s3-config-logs-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-config-logs-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.config_logs,
  ]
}

resource "aws_s3_bucket_public_access_block" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

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
    aws_s3_bucket_versioning.config_logs,
  ]
}

resource "aws_s3_bucket_versioning" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_policy" "config_logs" {
  bucket = aws_s3_bucket.config_logs.id
  policy = data.aws_iam_policy_document.config_logs.json
}

data "aws_iam_policy_document" "config_logs" {
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [
      aws_s3_bucket.config_logs.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.config_logs.arn,
    ]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.config_logs.arn}/*",
    ]

    principals {
      type = "Service"
      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }
}

# ===============================================================================
# S3 Bucket for Secure Informaion
# ===============================================================================
resource "aws_s3_bucket" "secure_info" {
  bucket        = "${local.project}-${local.env}-s3-secure-info-bucket"
  force_destroy = true

  tags = {
    Name = "${local.project}-${local.env}-s3-secure-info-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.secure_info,
  ]
}

resource "aws_s3_bucket_public_access_block" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id

  block_public_policy     = true
  block_public_acls       = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_info" {
  bucket = aws_s3_bucket.secure_info.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "secure_info" {
  bucket = aws_s3_bucket.secure_info.id

  versioning_configuration {
    status = "Disabled"
  }
}
