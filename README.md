# Cloud-Design

A modular microservices cloud infrastructure provisioned on AWS using **Terraform (IaC)** and **Amazon ECS (EC2 / Fargate)**.

> 📖 **Interactive Visual Documentation**: Open [cloud-design](https://kill-ux.github.io/cloud-design/)

---

## 🏗 Architecture Overview

```text

                        +---------------------------------------+
                        |        Application Load Balancer      |
                        +-------------------+-------------------+
                                            |
                                    (Public Subnet)
                                            |
  +-----------------------------------------v-----------------------------------------+
  |                                   Private Subnet                                  |
  |                                                                                   |
  |  +------------------+         +-------------------+         +------------------+  |
  |  |   API Gateway    | -------->   RabbitMQ AMQP   <-------- |   Billing App    |  |
  |  |    (Port 3000)   |         |    (Port 5672)    |         |    (Port 8080)   |  |
  |  +--------+---------+         +-------------------+         +--------+---------+  |
  |           |                                                          |            |
  |           v                                                          v            |
  |  +------------------+                                       +------------------+  |
  |  |  Inventory App   |                                       |   Billing DB     |  |
  |  |    (Port 8080)   |                                       |  (PostgreSQL)    |  |
  |  +--------+---------+                                       +------------------+  |
  |           |                                                                       |
  |           v                                                                       |
  |  +------------------+                                                             |
  |  |   Inventory DB   |                                                             |
  |  |   (PostgreSQL)   |                                                             |
  |  +------------------+                                                             |
  +-----------------------------------------------------------------------------------+
```

---

## 📦 What's Included

### 1. **Infrastructure as Code (Terraform)**

Located in `file:///home/muboutoub/projects/cloud-design/terraform`:

- **VPC Module**: Custom VPC with public and private subnets, Internet Gateway, NAT Gateways, and VPC Endpoints (`s3`, `ecr.api`, `ecr.dkr`, `logs`).
- **ECS Cluster & ASG**: ECS cluster backed by EC2 Auto Scaling Group (ASG) capacity providers, integrated with AWS Service Discovery (Cloud Map).
- **ALB Module**: Application Load Balancer with HTTP listeners, target groups, and security groups.
- **ECR Repositories**: Elastic Container Registry repositories for app images.
- **IAM Module**: ECS execution and task roles with policies for CloudWatch logging and ECR access.
- **Security Groups Module**: Fine-grained security groups enforcing principle of least privilege between ALB, API Gateway, services, broker, and databases.

### 2. **Microservices Stack**

- **API Gateway (`port 3000`)**: Entry point for HTTP routing to backend services and messaging.
- **Inventory Service (`port 8080`)**: Microservice managing inventory resources.
- **Billing Service (`port 8080`)**: Microservice handling billing operations.
- **RabbitMQ (`port 5672`)**: Asynchronous message broker connecting API Gateway and Billing tasks.
- **Databases (`port 5432`)**: PostgreSQL database services for Inventory and Billing datasets.

### 3. **Local Development (Docker)**

clone

```bash
git clone https://github.com/kill-ux/cloud-design.git
```

Located in `cloud-design/docker`:

- Complete local environment matching production services via `docker-compose.yml`.

---

## 📁 Repository Structure

```text
cloud-design/
├── docker/                 # Local docker environment & source code
│   ├── srcs/               # Microservices source code
│   └── docker-compose.yml  # Local multi-container development setup
├── terraform/              # Infrastructure as Code
│   ├── main.tf             # Core terraform module invocations
│   ├── provider.tf         # AWS provider & S3 remote state configuration
│   ├── services.tf         # Service definitions (ECS tasks & security groups)
│   ├── variables.tf        # Environment input variables
│   ├── output.tf           # Infrastructure output attributes
│   └── modules/            # Reusable Terraform modules
│       └── aws/            # AWS modules (vpc, ecs, alb, ecr, iam, security_group)
├── Makefile                # Command shortcuts for Terraform & AWS operations
├── README.md               # Project documentation
└── todo.todo               # Deployment notes & operational commands
```

---

## 🚀 Quick Start

### Prerequisites

- [AWS CLI](https://aws.amazon.com/cli/) configured with proper credentials
- [Terraform >= 1.0](https://www.terraform.io/)
- [Docker](https://www.docker.com/) & Docker Compose
- `make` utility

### Local Development (Docker)

```bash
cd docker
docker-compose up --build
```

### Infrastructure Deployment (Terraform)

1. **Initialize configuration**:

   ```bash
   cd terraform
   cp terraform.tfvars.example env.tfvars
   # Edit env.tfvars with your AWS region, credentials, and settings
   ```

2. **Deploy with Makefile**:

   ```bash
   # From root directory
   make init       # Initialize Terraform
   make validate   # Check Terraform code validity
   make plan       # Preview infrastructure changes
   make apply      # Deploy infrastructure to AWS
   ```

---

## 🛠 Useful Operations Commands

Run `make help` to view all available commands:

| Command | Description |
| :--- | :--- |
| `make plan` | Preview Terraform execution plan |
| `make apply` | Apply infrastructure changes |
| `make destroy` | Teardown provisioned infrastructure |
| `make ssh` | SSH into running ECS host EC2 instance |
| `make cluster` | Show current ECS Cluster status |
| `make services` | List active ECS services |
| `make lint` | Run Terraform format and validation checks |
