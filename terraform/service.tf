# ============================================================
# CloudWatch Log Group for Order Service
# ============================================================

# Explicit log group so logs are predictable and lifecycle-managed
resource "aws_cloudwatch_log_group" "order_service" {
  name              = "/ecs/${var.project_name_prefix}/order-service"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-order-service-logs"
    Environment = var.environment
  }
}

# ============================================================
# Application Load Balancer (Public)
# ============================================================

resource "aws_lb" "order_service" {
  name               = "${var.project_name_prefix}-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
  }
}

# ============================================================
# ALB Target Group
# ============================================================

resource "aws_lb_target_group" "order_service" {
  name        = "${var.project_name_prefix}-tg"
  port        = 8081
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-tg"
    Environment = var.environment
  }
}

# ============================================================
# ALB Listener (HTTP)
# ============================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.order_service.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.order_service.arn
  }
}

# ============================================================
# ECS Service (Fargate)
# ============================================================

resource "aws_ecs_service" "order_service" {
  name            = "${var.project_name_prefix}-order-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.order_service.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.order_service.arn
    container_name   = "order-service"
    container_port   = 8081
  }

  depends_on = [
    aws_lb_listener.http,
    aws_cloudwatch_log_group.order_service
  ]

  tags = {
    Name        = "${var.project_name}-order-service"
    Environment = var.environment
  }
}
