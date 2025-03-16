# ===============================================================================
# ECR for NginX (Base Image)
# ===============================================================================
resource "aws_ecr_repository" "nginx_base" {
  name                 = "${local.project}/base/nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.project}-${local.env}-ecr-nginx-base"
  }
}


# ===============================================================================
# ECR for App (Base Image)
# ===============================================================================
resource "aws_ecr_repository" "app_base" {
  name                 = "${local.project}/base/app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.project}-${local.env}-ecr-app-base"
  }
}


# ===============================================================================
# ECR for NginX
# ===============================================================================
resource "aws_ecr_repository" "nginx" {
  name                 = "${local.project}/${local.env}/nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.project}-${local.env}-ecr-nginx"
  }
}

resource "aws_ecr_lifecycle_policy" "nginx" {
  repository = aws_ecr_repository.nginx.name

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep last 10 images"
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 10
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}


# ===============================================================================
# ECR for App
# ===============================================================================
resource "aws_ecr_repository" "app" {
  name                 = "${local.project}/${local.env}/app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.project}-${local.env}-ecr-app"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Keep last 10 images"
        "selection" : {
          "tagStatus" : "any",
          "countType" : "imageCountMoreThan",
          "countNumber" : 10
        },
        "action" : {
          "type" : "expire"
        }
      }
    ]
  })
}
