# ===============================================================================
# ALB
# ===============================================================================
resource "aws_lb" "main" {
  name                       = "${local.project}-${local.env}-main-external-alb"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false

  security_groups = [
    aws_security_group.alb.id,
  ]

  subnets = [
    for subnet in aws_subnet.public :
    subnet.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.bucket
    enabled = true
  }

  tags = {
    Name = "${local.project}-${local.env}-main-external-alb"
  }
}
