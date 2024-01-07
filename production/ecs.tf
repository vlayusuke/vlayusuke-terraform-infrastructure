# ===============================================================================
# ECS Cluster
# ===============================================================================
resource "aws_ecs_cluster" "main" {
  name = "${local.project}-${local.env}-ecs-cluster"

  tags = {
    Name = "${local.project}-${local.env}-ecs-cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]

  default_capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }
}


# ===============================================================================
# ECS Service for App
# ===============================================================================
resource "aws_ecs_service" "app" {
  name                               = "app"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = data.aws_ecs_task_definition.app.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  platform_version                   = "1.4.0"
  enable_execute_command             = true

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 0
  }

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_external_tg.arn
    container_name   = "nginx"
    container_port   = 80
  }

  network_configuration {
    subnets = [
      for subnet in aws_subnet.private :
      subnet.id
    ]
    security_groups = [
      aws_security_group.app.id,
    ]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      task_definition,
      desired_count,
    ]
  }

  depends_on = [
    aws_lb_target_group.alb_external_tg,
  ]

  tags = {
    Name = "${local.project}-${local.env}-ecs-service-app"
  }
}

resource "aws_appautoscaling_target" "app" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = 2
  max_capacity       = 4

  lifecycle {
    ignore_changes = [
      max_capacity,
      min_capacity,
    ]
  }
}

resource "aws_appautoscaling_policy" "app_scale_out" {
  name               = "scale-out"
  policy_type        = "StepScaling"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 120
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 2
    }
  }

  lifecycle {
    ignore_changes = [
      step_scaling_policy_configuration,
    ]
  }

  depends_on = [
    aws_appautoscaling_target.app,
  ]
}

resource "aws_appautoscaling_policy" "app_scale_in" {
  name               = "scale-in"
  policy_type        = "StepScaling"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 600
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  lifecycle {
    ignore_changes = [
      step_scaling_policy_configuration,
    ]
  }

  depends_on = [
    aws_appautoscaling_target.app,
  ]
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.project}-${local.env}-ecs-task-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_service.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile(
    "files/task_definitions/app.json",
    {
      project          = local.project
      env              = local.env
      region           = local.region
      log_group_prefix = "${local.project}-${local.env}"
    }
  )

  tags = {
    Name = "${local.project}-${local.env}-ecs-task-app"
  }
}

data "aws_ecs_task_definition" "app" {
  task_definition = aws_ecs_task_definition.app.family
}


# ===============================================================================
# ECS Service for Cron
# ===============================================================================
resource "aws_ecs_service" "cron" {
  name                               = "cron"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = data.aws_ecs_task_definition.cron.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  platform_version                   = "1.4.0"

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 0
  }

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets = [
      for subnet in aws_subnet.private :
      subnet.id
    ]
    security_groups = [
      aws_security_group.cron.id,
    ]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      task_definition,
      desired_count,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-service-cron"
  }
}

resource "aws_ecs_task_definition" "cron" {
  family                   = "${local.project}-${local.env}-ecs-task-cron"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_service.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile(
    "files/task_definitions/cron.json",
    {
      project          = local.project
      env              = local.env
      region           = local.region
      log_group_prefix = "${local.project}-${local.env}"
    }
  )

  tags = {
    Name = "${local.project}-${local.env}-ecs-task-cron"
  }
}

data "aws_ecs_task_definition" "cron" {
  task_definition = aws_ecs_task_definition.cron.family
}


# ===============================================================================
# ECS Service for Queue
# ===============================================================================
resource "aws_ecs_service" "queue" {
  name                               = "queue"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = data.aws_ecs_task_definition.queue.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  platform_version                   = "1.4.0"

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 0
  }

  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets = [
      for subnet in aws_subnet.private :
      subnet.id
    ]
    security_groups = [
      aws_security_group.queue.id,
    ]
  }

  lifecycle {
    ignore_changes = [
      capacity_provider_strategy,
      task_definition,
      desired_count,
    ]
  }

  tags = {
    Name = "${local.project}-${local.env}-ecs-service-queue"
  }
}

resource "aws_ecs_task_definition" "queue" {
  family                   = "${local.project}-${local.env}-ecs-task-queue"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_service.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile(
    "files/task_definitions/queue.json",
    {
      project          = local.project
      env              = local.env
      region           = local.region
      log_group_prefix = "${local.project}-${local.env}"
    }
  )

  tags = {
    Name = "${local.project}-${local.env}-ecs-task-queue"
  }
}

data "aws_ecs_task_definition" "queue" {
  task_definition = aws_ecs_task_definition.queue.family
}


# ===============================================================================
# ECS Task for migrate
# ===============================================================================
resource "aws_ecs_task_definition" "migrate" {
  family                   = "${local.project}-${local.env}-ecs-task-migrate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_service.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = templatefile(
    "files/task_definitions/migrate.json",
    {
      project          = local.project
      env              = local.env
      region           = local.region
      log_group_prefix = "${local.project}-${local.env}"
    }
  )

  tags = {
    Name = "${local.project}-${local.env}-ecs-task-migrate"
  }
}
