# ===============================================================================
# KMS for Application
# ===============================================================================
resource "aws_kms_key" "application" {
  description         = "${local.project}-${local.env}-kms-application-key"
  enable_key_rotation = true

  tags = {
    Name = "${local.project}-${local.env}-kms-application-key"
  }
}


# ===============================================================================
# KMS for Aurora
# ===============================================================================
resource "aws_kms_key" "aurora" {
  description             = "${local.project}-${local.env}-kms-aurora-key"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7

  tags = {
    Name = "${local.project}-${local.env}-kms-aurora-key"
  }
}
