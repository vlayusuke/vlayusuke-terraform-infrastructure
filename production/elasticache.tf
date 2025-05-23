# ===============================================================================
# ElastiCache
# ===============================================================================
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${local.project}-${local.env}-ec-redis-cluster"
  description                = "ElastiCache Replication group for ${local.project}"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.t4g.medium"
  num_cache_clusters         = 2
  multi_az_enabled           = true
  automatic_failover_enabled = true
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.redis.id
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  maintenance_window         = "sat:14:00-sat:15:00"
  snapshot_retention_limit   = 14
  snapshot_window            = "15:00-16:00"

  security_group_ids = [
    aws_security_group.redis.id,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ec-redis-cluster"
  }
}

resource "aws_elasticache_parameter_group" "redis" {
  name   = "${local.project}-${local.env}-redis-cache-params-ecpg"
  family = "redis7"

  parameter {
    name  = "cluster-enabled"
    value = "yes"
  }

  tags = {
    Name = "${local.project}-${local.env}-redis-cache-params-ecpg"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name = "${local.project}-${local.env}-redis-cluster-subg"

  subnet_ids = [
    for subnet in aws_subnet.production_private :
    subnet.id
  ]

  tags = {
    Name = "${local.project}-${local.env}-redis-cluster-subg"
  }
}
