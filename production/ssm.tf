# ===============================================================================
# SSM Parameters for RDS
# ===============================================================================
resource "aws_ssm_parameter" "app_mysql_password" {
  name        = "/${local.project}/${local.env}/app-mysql-password"
  description = "The parameter for mysql password"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "Please Change!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-app-mysql-password"
  }
}


# ===============================================================================
# SSM Parameters for Application
# ===============================================================================
resource "aws_ssm_parameter" "app_key" {
  name        = "/${local.project}/${local.env}/app-key"
  description = "The parameter for ${local.project}-${local.env} app key"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "Please Change!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-app-key"
  }
}

resource "aws_ssm_parameter" "jwt_secret" {
  name        = "/${local.project}/${local.env}/jwt-secret"
  description = "The parameter for ${local.project}-${local.env} jwt secret"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "Please Change!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-jwt-secret"
  }
}

resource "aws_ssm_parameter" "aurora_writer_endpoint" {
  name        = "/${local.project}/${local.env}/aurora-writer-host"
  description = "The parameter for ${local.project}-${local.env} cluster endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "Please Change!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-aurora-writer-host"
  }
}

resource "aws_ssm_parameter" "aurora_reader_endpoint" {
  name        = "/${local.project}/${local.env}/aurora-reader-host"
  description = "The parameter for ${local.project}-${local.env} reader endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "Please Change!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-aurora-reader-host"
  }
}

resource "aws_ssm_parameter" "ec_writer_endpoint" {
  name        = "/${local.project}/${local.env}/ec-writer-host"
  description = "The parameter for ${local.project}-${local.env} ec cluster endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "Please Change!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-ec-writer-host"
  }
}

resource "aws_ssm_parameter" "ec_reader_endpoint" {
  name        = "/${local.project}/${local.env}/ec-reader-host"
  description = "The parameter for ${local.project}-${local.env} ec reader endpoint"
  key_id      = aws_kms_key.application.key_id
  type        = "SecureString"
  value       = "Please Change!"

  lifecycle {
    ignore_changes = [
      value,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ssm-aurora-reader-host"
  }
}
