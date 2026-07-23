# AWS ECS Task & Service Module

This module defines an individual **ECS Task Definition** (using `awsvpc` network mode), a **CloudWatch Log Group**, an **ECS Service**, and optional integration with **AWS Service Connect** or an **Application Load Balancer Target Group**.

---

## Resources Created

| Resource | Type | Description |
| :--- | :--- | :--- |
| `aws_cloudwatch_log_group.task_logs` | CloudWatch Log Group | Dedicated log stream `/ecs/{task_name}` |
| `aws_ecs_task_definition.task` | Task Definition | ECS Task with container mappings, logs, and resource limits |
| `aws_ecs_service.service` | ECS Service | Service maintaining desired running container task instances |

---

## Key Inputs (Variables)

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `task_name` | `string` | **Required** | Name of the task family and service |
| `container_image` | `string` | **Required** | Docker container image URL in ECR |
| `container_port` | `number` | **Required** | Port exposed by container |
| `port_name` | `string` | `""` | Name of the port mapping for Service Connect |
| `cluster_id` | `string` | **Required** | Parent ECS Cluster ID |
| `capacity_provider_name` | `string` | **Required** | Capacity provider strategy name |
| `execution_role_arn` | `string` | **Required** | IAM Execution Role ARN |
| `subnets` | `list(string)` | **Required** | Subnet IDs for network interface creation (`awsvpc`) |
| `security_groups` | `list(string)` | **Required** | Security Group IDs attached to task |
| `cpu` | `number` | `128` | Container CPU units |
| `memory` | `number` | `256` | Container Memory (MB) |
| `environment_variables` | `list(object)` | `[]` | Environment variables injected into container |
| `target_group_arn` | `string` | `""` | Optional ALB Target Group ARN |

---

## Outputs

| Name | Description |
| :--- | :--- |
| `service_id` | ARN / ID of the created ECS service |
| `task_definition_arn` | Full ARN of the generated Task Definition |
| `discovery_name` | Service Discovery DNS name |

---

## Usage Example

```hcl
module "inventory_service" {
  source          = "./modules/aws/ecs_task"
  task_name       = "inventory"
  container_image = "${var.ecr_registry}/inventory-app:1.0.0"
  container_port  = 8080
  port_name       = "inventory"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = module.iam.ecs_execution_role_arn
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn

  subnets         = module.vpc.private_subnet_ids
  security_groups = [module.inventory_sg.id]
}
```

---

## Best Practices & Requirements

- **Secret Handling**: For passwords and API keys, prefer injecting values via AWS Secrets Manager ARNs (`secrets`) instead of plain text environment variables.
- **Resource Limits**: Benchmark CPU and Memory settings for each container to avoid Out-Of-Memory (OOM) task kills.
