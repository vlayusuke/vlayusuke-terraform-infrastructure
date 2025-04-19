# ================================================================================
# S3 Bucket for Bastion
# ================================================================================
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


# ================================================================================
# S3 Bucket for Source Code Backup
# ================================================================================
resource "aws_s3_bucket" "source_backup_tokyo" {
  bucket = "${local.project}-${local.env}-s3-github-backup-tokyo-bucket"

  tags = {
    Name = "${local.project}-${local.env}-s3-github-backup-tokyo-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "source_backup_tokyo" {
  bucket = aws_s3_bucket.source_backup_tokyo.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "source_backup_tokyo" {
  bucket = aws_s3_bucket.source_backup_tokyo.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.source_backup_tokyo,
  ]
}

resource "aws_s3_bucket_public_access_block" "source_backup_tokyo" {
  bucket = aws_s3_bucket.source_backup_tokyo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "source_backup_tokyo" {
  bucket = aws_s3_bucket.source_backup_tokyo.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "source_backup_tokyo" {
  bucket = aws_s3_bucket.source_backup_tokyo.id

  versioning_configuration {
    status = "Enabled"
  }
}
