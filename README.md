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
│   └── aws/
│       └── terraform.tfvars
│
├── scripts/
│   └── infra-destroy.sh
│
├── order-service-aws.postman_collection.json
└── README.md
```

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

## Deployment Flow (Manual – Current State)

> ⚠️ Deployment is intentionally **manual** at this stage.

Terraform manages ECS, ALB, networking and RDS.
Application deployment occurs via ECS service update pulling the latest image.


### 1. Build Application Artifact

- Build Spring Boot application
- Package executable JAR
- Performed in `order-system-services` repository

### 2. Build Docker Image

- Dockerfile lives in `order-system-services/order-service`
- Image built locally
- Tag: `order-processing-system-order-service:latest`

### 3. Push Image to Amazon ECR

- Authenticate Docker to ECR
- Tag image with ECR repository URI
- Push image

### 4. Provision / Update Infrastructure (Terraform)

- terraform init
- terraform plan
- terraform apply

Terraform manages ECS, ALB, networking and RDS.

### 5. Verify Deployment

- Use ALB DNS endpoint
- Validate with Postman collection:
  - Health check
  - Create order
  - Get order
  - Cancel order

### 6. Infrastructure Teardown

- Manual destroy to control cloud costs
- Script: `scripts/infra-destroy.sh`

---

## CI/CD Status

### Infrastructure

- No automated apply
- No remote state
- Manual lifecycle

### Application

- CI/CD temporarily frozen
- Will be revisited after documentation iteration

---

## Relationship to Other Repositories

- **order-system-services**
  - Application code and Docker images

- **order-system-infrastructure**
  - Cloud provisioning and deployment topology

---

## Future Evolution

Planned but postponed:

- Remote Terraform backend
- Multiple environments
- CI/CD automation
- Visual infrastructure diagrams
- Observability
