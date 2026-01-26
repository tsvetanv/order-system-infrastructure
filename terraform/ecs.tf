locals {
  service_name = "order-service"
}

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name_prefix}-ecs-cluster"
}

# ============================================================
# ECR Repository for Order Service
# ============================================================

resource "aws_ecr_repository" "order_service" {
  name                 = "${var.project_name}-${local.service_name}"
  image_tag_mutability = "MUTABLE"

  # allow Terraform to delete images when destroying infra
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${local.service_name}"
    Environment = var.environment
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

# ============================================================
# IAM Roles for ECS (Execution + Task)
# ============================================================

# IAM role assumed by ECS agent to:
# - pull images from ECR
# - write logs to CloudWatch
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name_prefix}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS-managed policy required for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role      = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM role assumed by the application container itself
# Used for runtime AWS access (e.g. Secrets Manager, SSM)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ============================================================
# ECS Task Definition for Order Service (Fargate)
# ============================================================

resource "aws_ecs_task_definition" "order_service" {
  family                   = "${var.project_name_prefix}-order-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "order-service"
      image     = "${aws_ecr_repository.order_service.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8081
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "SPRING_PROFILES_ACTIVE"
          value = "aws"
        },
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:postgresql://${aws_db_instance.postgres.endpoint}/${var.db_name}"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = var.db_username
        },
        {
          name  = "SPRING_DATASOURCE_PASSWORD"
          value = var.db_password
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.project_name_prefix}/order-service"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
