# Order Processing System – Infrastructure

## Overview

This repository contains the **Infrastructure as Code (IaC)** for the  
**Order Processing System**, implemented using **Terraform** and deployed on **AWS**.

Its purpose is to:

- Define and document the **cloud infrastructure architecture**
- Provide a **clear, evolvable Terraform structure**
- Separate infrastructure concerns from application code

At this stage, the infrastructure is **intentionally simple, single-environment, and manually operated**.  
Automation and multi-environment support will be introduced in later iterations.

---

## Scope & Principles

This repository follows these principles:
 
- Infrastructure is treated as **code**
- Infrastructure evolves **incrementally**, aligned with architectural maturity
- Clear separation between:
  - infrastructure provisioning
  - application build & deployment
- Explicit and manual control over **cloud cost lifecycle**

---

## Repository Structure

```
order-system-infrastructure
│
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── networking.tf
│   ├── security.tf
│   ├── rds.tf
│   ├── ecs.tf
│   └── service.tf
│
├── envs/
│   ├── local/
│   │   ├── backend.hcl
│   │   └── terraform.tfvars
│   │
│   └── aws/
│       ├── backend.hcl
│       └── terraform.tfvars
│
├── scripts/
│   └── infra-destroy.sh
│
└── README.md
```

---

## Environment Model

This repository uses a **single Terraform root** with **explicit environment configuration**.

Environment differences are expressed via:
- `backend.hcl` → where Terraform state is stored
- `terraform.tfvars` → environment-specific values

Currently supported environments:

| Environment | Purpose | Backend |
|-----------|--------|--------|
| `local` | Local / dev-friendly configuration | local state |
| `aws` | Real AWS infrastructure | local state (AWS resources) |

> ⚠️ There is **no automatic environment switching**.  
> The environment is selected explicitly when running Terraform.


---

## Current State

### Infrastructure

- Cloud provider: **AWS**
- Region: **eu-central-1**
- Environment model: **single environment**
- Terraform backend: **local**
- State management: **manual**
- Apply/destroy: **manual**

### Core AWS Components

- VPC (custom)
- Application Load Balancer (ALB)
- ECS Cluster (Fargate)
- ECS Service (Order Service)
- RDS PostgreSQL (orders database)
- Security Groups (ALB ↔ ECS ↔ RDS)

---

## Network Architecture

```
Internet
   |
   v
Application Load Balancer (ALB) [public]
   |
   v
ECS Service (Fargate)
   |
   v
Order Service (Spring Boot, port 8081)
   |
   v
PostgreSQL Database (Amazon RDS)
```

---

---

## Running Terraform (Most Important Section)

All Terraform commands are executed from the **repository root**, targeting the  
`terraform/` directory via `-chdir`.

### General Rules

- Terraform is **always executed from `terraform/`**
- Environment is selected explicitly via:
  - `-backend-config=../envs/<env>/backend.hcl`
  - `-var-file=../envs/<env>/terraform.tfvars`
- There is **no implicit default environment**

---

## Terraform Init

Initializes Terraform and configures the backend.

### AWS environment
```bash
terraform -chdir=terraform init -backend-config=../envs/aws/backend.hcl
```

### Local
```bash
    terraform -chdir=terraform init -backend-config=../envs/local/backend.hcl
```
---

## Terraform Plan

### AWS
```bash
    terraform -chdir=terraform plan -var-file=../envs/aws/terraform.tfvars
```
### Local
```bash
    terraform -chdir=terraform plan -var-file=../envs/local/terraform.tfvars
```
---

## Terraform Apply

### AWS
```bash
    terraform -chdir=terraform apply -var-file=../envs/aws/terraform.tfvars
```
### Local
```bash
    terraform -chdir=terraform apply -var-file=../envs/local/terraform.tfvars
```
---

## Terraform Destroy

### AWS
```bash
    terraform -chdir=terraform destroy -var-file=../envs/aws/terraform.tfvars
```
### Local
```bash
    terraform -chdir=terraform destroy -var-file=../envs/local/terraform.tfvars
```
---

## Infrastructure Teardown Script

### AWS
Destroy AWS infrastructure
```bash
    ./scripts/infra-destroy.sh aws
```

### Local
Destroy local environment
```bash
    ./scripts/infra-destroy.sh local
```

---

## Future Evolution

-   Remote Terraform backend
-   Multiple environments
-   CI/CD automation
-   Observability