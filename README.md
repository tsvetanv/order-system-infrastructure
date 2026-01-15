# Order Processing System – Infrastructure

## Overview

This repository contains the **Infrastructure as Code (IaC)** foundation for the
Order Processing System.

Its purpose is to provide a **clean, evolvable Terraform project structure**
that supports multiple environments and future cloud deployment, while keeping
infrastructure concerns clearly separated from application code.

At the current stage, the repository contains **bootstrap-level configuration only**.
No cloud providers or infrastructure resources are defined yet.

---

## Scope & Principles

This repository follows these principles:

- Infrastructure is treated as **code**
- Infrastructure evolves **incrementally**, together with the system architecture
- Environment isolation is enforced via **separate Terraform backends**
- Cloud-specific decisions are introduced **intentionally and later**

The initial focus is on **structure, boundaries, and readiness**, not provisioning.

---

## Repository Structure

```
order-system-infrastructure
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── envs/
│   └── local/
│       └── backend.tf
│
├── .gitignore
└── README.md
```

### terraform/

Contains the **core Terraform configuration** shared by all environments.

- No environment-specific logic
- No cloud providers at bootstrap stage
- Serves as the foundation for future infrastructure definitions

### envs/

Contains **environment-specific configuration**, primarily backend definitions.

Each environment:
- Uses the same Terraform code
- Has its own backend and state
- Is fully isolated from other environments

Currently defined:
- local – local backend for development and experimentation

Future environments will be added here (e.g. dev, staging, prod).

---

## Environment Strategy

The project uses an **environment-per-backend** approach:

- One Terraform state per environment
- No shared state between environments
- Safe parallel evolution of environments

This approach supports both local development and future cloud deployments
without structural changes to the repository.

---

## Current State

- Terraform backend: local
- Environments: local
- Providers: none
- Resources: none

This is a deliberate starting point that enables early validation of
infrastructure structure without premature cloud coupling.

---

## Relationship to Other Repositories

- order-system-services  
  Application code, runtime configuration, and containerization

- order-system-infrastructure  
  Infrastructure definitions and environment provisioning

The two repositories evolve together but remain **loosely coupled**.

---

## Future Evolution

In subsequent iterations, this repository will be extended with:

- Cloud provider configuration (AWS)
- Remote state backends
- Additional environments (dev, staging, prod)
- Networking, compute, and database resources
- Deployment and observability infrastructure

These additions will build on the existing structure without requiring rework.

---

## Notes

This repository intentionally favors **clarity and structure** over completeness.
Infrastructure will be added when architectural decisions are validated and stable.

## CI/CD & Infrastructure Lifecycle

This repository defines the infrastructure lifecycle for the
Order Processing System using Terraform.

The CI pipeline validates infrastructure code by running:

- terraform init
- terraform validate

Infrastructure is applied manually to preserve control
during early system iterations.

### Relationship to Application CI

Application build and container image publication are handled
in the `order-system-services` repository.

This repository focuses exclusively on infrastructure provisioning.
