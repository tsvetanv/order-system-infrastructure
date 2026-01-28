# ============================================================
# IAM Role for GitHub Actions (OIDC)
# Used for application CI/CD only (ECR push + ECS deploy)
# ============================================================

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "github_actions_deployer" {
  name = "${var.project_name_prefix}-github-actions-deployer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repository_owner}/order-system-services:ref:refs/heads/main"
          }

        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_deployer_policy" {
  role = aws_iam_role.github_actions_deployer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # Push images to ECR
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },

      # Trigger ECS deployment
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = "*"
      }
    ]
  })
}
