resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-ecs-cluster"
}

# ============================================================
# ECR Repository for Order Service
# ============================================================

resource "aws_ecr_repository" "order_service" {
  name                 = "order-processing-system/order-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "order-processing-system-order-service"
    Environment = "aws"
  }
}

# Allow lifecycle cleanup to avoid unlimited image growth
resource "aws_ecr_lifecycle_policy" "order_service" {
  repository = aws_ecr_repository.order_service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
