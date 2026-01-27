# Order Processing System (OPS) – Infrastructure Handbook

This handbook describes **step-by-step** how to provision, deploy, verify, and destroy the **Order Processing System (OPS)** infrastructure.

It is based on **Iteration 4 – Infrastructure** and reflects the **exact commands and decisions** validated during implementation.

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

---

## Repository Structure

```
order-system/
├── order-system-infrastructure/
│   ├── terraform/
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

Run **inside the order-service directory** where the Dockerfile exists.

```
cd /mnt/d/repo/order-system/order-system-services/order-service && docker build -t order-processing-system-order-service:latest .
```

---

## 3. Authenticate to AWS (WSL)

Verify credentials:

```
aws sts get-caller-identity
```

Login to ECR:

```
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 669930940049.dkr.ecr.eu-central-1.amazonaws.com
```

---

## 4. Tag & Push Image to ECR (WSL)

```
docker tag order-processing-system-order-service:latest 669930940049.dkr.ecr.eu-central-1.amazonaws.com/order-processing-system-order-service:latest
```

```
docker push 669930940049.dkr.ecr.eu-central-1.amazonaws.com/order-processing-system-order-service:latest
```

---

## 5. Provision Infrastructure (GitHub Bash)

Run Terraform **only from GitHub Bash**.

```
cd /d/repo/order-system/order-system-infrastructure && terraform -chdir=terraform init -backend-config=../envs/aws/backend.hcl
```

```
cd /d/repo/order-system/order-system-infrastructure && terraform -chdir=terraform apply -var-file=../envs/aws/terraform.tfvars
```

---

## 6. Deploy Service on ECS (WSL)

Force ECS to pull the newly pushed image:

```
aws ecs update-service --cluster ops-ecs-cluster --service ops-order-service --force-new-deployment
```

Verify service status:

```
aws ecs describe-services --cluster ops-ecs-cluster --services ops-order-service
```

---

## 7. Verify Application Health (WSL)

Retrieve ALB DNS name:

```
terraform -chdir=terraform output -raw alb_dns_name
```

Health check:

```
curl http://<alb-dns-name>/actuator/health
```

Expected output:

```
{"status":"UP"}
```

---

## 8. Destroy Infrastructure (GitHub Bash)

Use the provided cleanup script **to avoid AWS costs**.

```
cd /d/repo/order-system/order-system-infrastructure && ./scripts/infra-destroy.sh aws
```

Expected final output:

```
Destroy complete! Resources: XX destroyed.
Infrastructure destroyed for environment: aws
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

Explicitly excluded:
- CI/CD pipelines (handled next)
- Multiple environments
- Secrets Manager / SSM
- Auto-scaling


