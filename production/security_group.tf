# ===============================================================================
# Security Group for ALB
# ===============================================================================
resource "aws_security_group" "alb" {
  name        = "${local.project}-${local.env}-alb-sg"
  description = "Security Group for ${local.project}-${local.env} External ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-alb-sg"
  }
}


# ===============================================================================
# Security Group for VPC Endpoint (ECR - Docker)
# ===============================================================================
resource "aws_security_group" "ecr_vpce" {
  name        = "${local.project}-${local.env}-vpce-ecr-sg"
  description = "Security Group for VPC EndPoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Container Security Group"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [
      aws_security_group.app.id,
      aws_security_group.cron.id,
      aws_security_group.queue.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-vpce-ecr-sg"
  }
}


# ===============================================================================
# Security Group for VPC Endpoint (SSM)
# ===============================================================================
resource "aws_security_group" "ssm_vpce" {
  name        = "${local.project}-${local.env}-vpce-ssm-sg"
  description = "Security Group for SSM VPC EndPoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "VPC Security Group"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      aws_vpc.main.cidr_block,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-vpce-ssm-sg"
  }
}


# ===============================================================================
# Security Group for VPC Endpoint (SNS)
# ===============================================================================
resource "aws_security_group" "sns_vpce" {
  name        = "${local.project}-${local.env}-vpce-sns-sg"
  description = "Security Group for SNS VPC EndPoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "VPC Security Group"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      aws_vpc.main.cidr_block,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-vpce-sns-sg"
  }
}


# ===============================================================================
# Security Group for Fargate (App)
# ===============================================================================
resource "aws_security_group" "app" {
  name        = "${local.project}-${local.env}-fargate-app-sg"
  description = "security group for ${local.project}-${local.env} Fargate app"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "alb"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      aws_security_group.alb.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-fargate-app-sg"
  }
}


# ===============================================================================
# Security Group for Fargate (cron)
# ===============================================================================
resource "aws_security_group" "cron" {
  name        = "${local.project}-${local.env}-fargate-cron-sg"
  description = "security group for ${local.project}-${local.env} Fargate cron"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "app"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    security_groups = [
      aws_security_group.app.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-fargate-cron-sg"
  }
}


# ===============================================================================
# Security Group for Fargate (queue)
# ===============================================================================
resource "aws_security_group" "queue" {
  name        = "${local.project}-${local.env}-fargate-queue-sg"
  description = "security group for ${local.project}-${local.env} Fargate queue"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "app"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    security_groups = [
      aws_security_group.app.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-fargate-queue-sg"
  }
}


# ===============================================================================
# Security Group for Aurora
# ===============================================================================
resource "aws_security_group" "rds" {
  name        = "${local.project}-${local.env}-rds-sg"
  description = "Security Group for ${local.project}-${local.env} rds"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "app"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = [
      aws_security_group.app.id,
    ]
  }

  ingress {
    description = "cron"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = [
      aws_security_group.cron.id,
    ]
  }

  ingress {
    description = "queue"
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    security_groups = [
      aws_security_group.queue.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-rds-sg"
  }
}


# ===============================================================================
# Security Group for ElastiCache
# ===============================================================================
resource "aws_security_group" "redis" {
  name        = "${local.project}-${local.env}-redis-sg"
  description = "Security Group for ${local.project}-${local.env} redis"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "app"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    security_groups = [
      aws_security_group.app.id,
    ]
  }

  ingress {
    description = "cron"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    security_groups = [
      aws_security_group.cron.id,
    ]
  }

  ingress {
    description = "queue"
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    security_groups = [
      aws_security_group.queue.id,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-redis-sg"
  }
}
