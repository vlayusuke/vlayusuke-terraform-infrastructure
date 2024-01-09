# ===============================================================================
# S3 Bucket for Bastion
# ===============================================================================
resource "aws_s3_bucket" "bastion" {
  bucket = "${local.project}-${local.env}-s3-bastion-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-bastion-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "bastion" {
  bucket = aws_s3_bucket.bastion.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bastion" {
  bucket = aws_s3_bucket.bastion.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.bastion,
  ]
}

resource "aws_s3_bucket_public_access_block" "bastion" {
  bucket = aws_s3_bucket.bastion.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bastion" {
  bucket = aws_s3_bucket.bastion.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bastion" {
  bucket = aws_s3_bucket.bastion.id
  versioning_configuration {
    status = "Enabled"
  }
}

