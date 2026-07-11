# Cloud-Design

## Architecture

VPC → ALB → ECS (Fargate) → RDS (PostgreSQL)

Components:

- API Gateway (ECS Fargate) - Port 3000
- Inventory App (ECS Fargate) - Port 8080
- Billing App (ECS Fargate) - Port 8080
- RabbitMQ (ECS Fargate) - Port 5672
- Inventory DB (RDS PostgreSQL) - Port 5432
- Billing DB (RDS PostgreSQL) - Port 5432

## Prerequisites

- AWS Account
- Terraform
- Docker
- AWS CLI

## Setup

### 1. Clone and configure

```bash
git clone [<repo>](https://github.com/kill-ux/cloud-design.git)
cd cloud-design
cp terraform/terraform.tfvars.example terraform/env.tfvars
# Edit env.tfvars with your values