# ===============================================================================
# Aurora Cluster
# ===============================================================================
resource "aws_rds_cluster" "aurora" {
  cluster_identifier              = "${local.project}-${local.env}-aurora-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.08.1"
  database_name                   = local.database_name
  master_username                 = local.database_master_user_name
  master_password                 = aws_ssm_parameter.app_mysql_password.value
  backup_retention_period         = 14
  preferred_backup_window         = "20:00-20:30"
  preferred_maintenance_window    = "sat:20:30-sat:21:00"
  db_subnet_group_name            = aws_db_subnet_group.aurora.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora.name
  final_snapshot_identifier       = "${local.project}-${local.env}-aurora-cluster-snapshot"
  deletion_protection             = true
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.aurora.arn
  enabled_cloudwatch_logs_exports = local.enabled_cloudwatch_logs_exports

  vpc_security_group_ids = [
    aws_security_group.rds.id,
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      database_name,
      master_username,
      master_password,
    ]
  }

  depends_on = [
    aws_ssm_parameter.app_mysql_password,
  ]

  tags = {
    Name     = "${local.project}-${local.env}-aurora-cluster"
    AutoStop = "true"
  }
}

resource "aws_db_subnet_group" "aurora" {
  name = "${local.project}-${local.env}-aurora-cluster-subg"
  subnet_ids = [
    for subnet in aws_subnet.production_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-aurora-cluster-subg"
  }
}


# ===============================================================================
# Aurora Instance
# ===============================================================================
resource "aws_rds_cluster_instance" "aurora" {
  count                                 = 2
  identifier                            = "${local.project}-${local.env}-aurora-instance-${count.index}"
  cluster_identifier                    = aws_rds_cluster.aurora.id
  engine                                = "aurora-mysql"
  instance_class                        = "db.t4g.medium"
  db_subnet_group_name                  = aws_db_subnet_group.aurora.id
  publicly_accessible                   = false
  db_parameter_group_name               = aws_db_parameter_group.aurora.name
  auto_minor_version_upgrade            = false
  performance_insights_enabled          = true
  performance_insights_kms_key_id       = aws_kms_key.aurora.arn
  performance_insights_retention_period = 7

  tags = {
    Name     = "${local.project}-${local.env}-aurora-instance-${count.index}"
    AutoStop = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  name        = "${local.project}-${local.env}-aurora-cluster-dbpg"
  family      = "aurora-mysql8.0"
  description = "RDS parameter group for ${local.project}"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "server_audit_logs_upload"
    value = "1"
  }

  parameter {
    name  = "server_audit_events"
    value = "connect,query_dcl,query_ddl,query_dml"
  }

  lifecycle {
    ignore_changes = [
      parameter,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-aurora-cluster-dbpg"
  }
}

resource "aws_db_parameter_group" "aurora" {
  name        = "${local.project}-${local.env}-aurora-instance-dbpg"
  family      = "aurora-mysql8.0"
  description = "RDS parameter group for ${local.project}"

  parameter {
    name  = "max_connections"
    value = local.rds_max_connections
  }

  parameter {
    name  = "slow_query_log"
    value = 1
  }

  parameter {
    name  = "long_query_time"
    value = 0.1
  }

  parameter {
    name  = "log_output"
    value = "file"
  }

  parameter {
    name  = "general_log"
    value = 1
  }

  tags = {
    Name = "${local.project}-${local.env}-aurora-instance-dbpg"
  }
}
