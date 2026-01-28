# Order Processing System (OPS) – Infrastructure Handbook

This handbook describes **step-by-step** how to provision, deploy, verify, and destroy the **Order Processing System (OPS)** infrastructure,
**including CI/CD prerequisites introduced after Iteration 4**.

It reflects the **exact commands, constraints, and decisions** validated during implementation.

---

## Tooling & Execution Environment

| Tool | Where it MUST run |
|-----|-------------------|
| Terraform | **GitHub Bash (Windows)** |
| Infrastructure scripts (`infra-destroy.sh`) | **GitHub Bash (Windows)** |
| Docker | **WSL** |
| AWS CLI (ECR, ECS, STS) | **WSL** |
| curl (health check) | **WSL** |

⚠️ **Important rules**
- Terraform is **NOT installed in WSL**
- Docker is **NOT available in GitHub Bash**
- All commands are **single-line commands only**
- CI/CD automation does **NOT** replace manual infrastructure provisioning

---

## Repository Structure

```
order-system/
├── order-system-infrastructure/
│   ├── terraform/
│   │   ├── ecs.tf
│   │   ├── github-actions-iam.tf
│   │   ├── networking.tf
│   │   ├── rds.tf
│   │   ├── security.tf
│   │   └── service.tf
│   ├── envs/aws/
│   └── scripts/
└── order-system-services/
    └── order-service/
```

---

## 1. Build Application JAR (WSL)

```
cd /mnt/d/repo/order-system/order-system-services && mvn clean package
```

---

## 2. Build Docker Image (WSL)

```
cd /mnt/d/repo/order-system/order-system-services/order-service && docker build -t order-processing-system-order-service:latest .
```

---

## 3. Authenticate to AWS (WSL)

Verify credentials:

```
aws sts get-caller-identity
```

---

## 4. Provision Infrastructure (GitHub Bash)

```
cd /d/repo/order-system/order-system-infrastructure && terraform -chdir=terraform init -backend-config=../envs/aws/backend.hcl
```

```
cd /d/repo/order-system/order-system-infrastructure && terraform -chdir=terraform apply -var-file=../envs/aws/terraform.tfvars
```

---

## 5. CI/CD Prerequisite – GitHub Actions IAM Role

CI/CD requires a **dedicated IAM role assumed via GitHub OIDC**.

This role is provisioned via Terraform:

- File: `terraform/github-actions-iam.tf`
- Role name: `ops-github-actions-deployer`

After `terraform apply`, retrieve the role ARN:

```
terraform -chdir=terraform output github_actions_role_arn
```

This ARN is required by the CI/CD pipeline.

---

## 6. Manual ECS Deployment (Fallback)

CI/CD automates this step, but manual deployment remains valid:

```
aws ecs update-service --cluster ops-ecs-cluster --service ops-order-service --force-new-deployment
```

---

## 7. Verify Application Health (Github Bash & WSL)

Retrieve ALB DNS name from Github Bash:

```
terraform -chdir=terraform output -raw alb_dns_name
```

Health check from WSL:

```
curl http://<alb-dns-name>/actuator/health
```

Expected output:

```
{"status":"UP"}
```

---

## 8. Destroy Infrastructure (GitHub Bash)

```
cd /d/repo/order-system/order-system-infrastructure && ./scripts/infra-destroy.sh aws
```

---

## Infrastructure Scope (Iteration 4)

Included:
- VPC, subnets, routing
- Security groups
- ALB + Target Group
- ECS Cluster (Fargate)
- ECS Service (order-service)
- ECR Repository
- RDS PostgreSQL
- GitHub Actions IAM role (CI/CD prerequisite)

Explicitly excluded:
- Terraform execution in CI
- Multi-environment setups
- Auto-scaling
- Secrets Manager / SSM
