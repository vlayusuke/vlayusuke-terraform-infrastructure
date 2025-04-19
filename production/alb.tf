# ===============================================================================
# ALB
# ===============================================================================
resource "aws_lb" "production_external" {
  name                       = "${local.project}-${local.env}-alb"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = false

  security_groups = [
    aws_security_group.alb.id,
  ]

  subnets = [
    for subnet in aws_subnet.production_public :
    subnet.id
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
  }

  tags = {
    Name = "${local.project}-${local.env}-alb"
  }
}

resource "aws_lb_listener" "alb_external_listener" {
  load_balancer_arn = aws_lb.production_external.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = aws_acm_certificate.production.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      status_code  = 404
      message_body = "<html><head><title>404 Not Found</title></head><body><h1>Not Found</h1><hr><address>Apache/2.2.31</address></body></html>"
    }
  }

  depends_on = [
    aws_acm_certificate_validation.production,
  ]

  tags = {
    Name = "${local.project}-${local.env}-alb-listener"
  }
}

resource "aws_lb_target_group" "alb_external_tg" {
  name                 = "${local.project}-${local.env}-alb-tg"
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.production.id
  deregistration_delay = 115

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 600
    enabled         = false
  }

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    path                = "/healthcheck"
    interval            = 30
    timeout             = 5
  }

  depends_on = [
    aws_lb.production_external,
  ]

  tags = {
    Name = "${local.project}-${local.env}-alb-tg"
  }
}

resource "aws_lb_listener_certificate" "alb_listener_cert" {
  listener_arn    = aws_lb_listener.alb_external_listener.arn
  certificate_arn = aws_acm_certificate.production.arn

  depends_on = [
    aws_lb_listener.alb_external_listener,
  ]
}


# ===============================================================================
# ALB Listener Rule
# ===============================================================================
resource "aws_lb_listener_rule" "app" {
  listener_arn = aws_lb_listener.alb_external_listener.arn

  condition {
    host_header {
      values = [
        local.domain,
      ]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_external_tg.arn
  }

  tags = {
    Name = "${local.project}-${local.env}-alb-listener-rule"
  }
}


# ===============================================================================
# Redirect Setting (WWW Domain to Naked Domain)
# ===============================================================================
resource "aws_lb_listener_rule" "naked" {
  listener_arn = aws_lb_listener.alb_external_listener.arn

  condition {
    host_header {
      values = [
        "www.${local.domain}",
      ]
    }
  }

  action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = 443
      host        = local.domain
      query       = ""
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "${local.project}-${local.env}-alb-listener-rule-redirect"
  }
}
