# Terraform Lab

## Overview

Terraform Lab is a hands-on infrastructure-as-code (IaC) project focused on building, testing, and validating cloud infrastructure using Terraform in a controlled local environment.

The primary goal of this repository is to:

- Develop production-like Terraform modules
- Validate infrastructure changes through automated tests
- Integrate Terraform workflows into CI/CD pipelines
- Ensure reproducibility and reliability of infrastructure changes

This repository is designed as a learning and experimentation platform with real-world DevOps practices applied from the beginning.

---

## Goals

1. Treat infrastructure as production-grade code.
2. Implement automated validation and testing.
3. Integrate Terraform into CI pipelines.
4. Use local cloud emulation to avoid unnecessary cloud costs.
5. Maintain clean, modular, reusable Terraform code.

---

## Architecture Approach

### Local Cloud Emulation

We use LocalStack to simulate AWS services locally. This allows:

- Fast feedback loops
- Zero cloud cost during development
- Safe testing of destructive operations
- Deterministic CI runs

### Infrastructure Definition

Infrastructure is defined using:

- Terraform modules
- Environment-based configurations (e.g., dev)
- Remote-state-ready structure (even if running locally)

### Testing Strategy

We validate infrastructure behavior using automated tests that:

- Deploy infrastructure
- Verify expected resources exist
- Destroy infrastructure
- Confirm cleanup behavior

---

## Repository Structure
```
.
├── terraform/ # Terraform root configurations
│ ├── environments/ # Environment-specific configs (e.g., dev)
│ └── modules/ # Reusable Terraform modules
│
├── tests/ # Automated infrastructure tests
│
├── .github/workflows/ # CI pipeline definitions
│
└── README.md
```

---

## Prerequisites

- Terraform
- Docker
- LocalStack
- Git
- (Optional) AWS CLI for debugging

---

## Local Development Workflow

### 1. Start LocalStack

```
docker compose up -d
```

### 2. Initialize Terraform

```
cd terraform/environments/dev
terraform init
```

### 3. Apply Infrastructure

```
terraform apply
```

### 4. Destroy Infrastructure

```
terraform destroy
```

---

## CI/CD Pipeline

The CI pipeline:

1. Starts LocalStack
2. Runs Terraform init
3. Executes Terraform plan
4. Applies infrastructure
5. Runs infrastructure tests
6. Destroys infrastructure
7. Fails if any validation step fails

This ensures infrastructure changes are continuously validated before merging.

---

## Design Decisions

- Local-first development to reduce cost and risk
- Modular Terraform structure for scalability
- Automated cleanup to avoid state drift
- CI validation before any merge
- No manual infrastructure steps

---

## Future Improvements

- Add multiple environments (staging, prod simulation)
- Introduce remote state backend
- Add policy validation (e.g., OPA or Terraform Cloud policies)
- Expand test coverage
- Add cost estimation checks

---

## Contribution Guidelines

1. Create a feature branch.
2. Keep Terraform modules reusable and isolated.
3. Run tests locally before pushing.
4. Ensure CI passes before merging.

---

## Objective

This repository is not just about provisioning resources.

It is about building infrastructure the same way we build production software:

- Version controlled
- Tested
- Automated
- Repeatable
- Reliable