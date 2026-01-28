output "vpc_id" {
  value = aws_vpc.main.id
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecr_repository_url" {
  description = "ECR repository URL for order-service"
  value       = aws_ecr_repository.order_service.repository_url
}

output "github_actions_role_arn" {
  description = "IAM Role assumed by GitHub Actions for CI/CD"
  value       = aws_iam_role.github_actions_deployer.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.order_service.dns_name
}
