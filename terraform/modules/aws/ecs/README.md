# AWS ECS Cluster & Auto Scaling Group Module

This module provisions an **Amazon ECS Cluster** integrated with Container Insights, Service Connect, an **Auto Scaling Group (ASG)** of EC2 instances, Launch Templates, and ECS Capacity Providers.

---

## Resources Created

| Resource | Type | Description |
| :--- | :--- | :--- |
| `aws_ecs_cluster.cloud_design_cluster` | ECS Cluster | ECS Cluster with Container Insights & Service Connect enabled |
| `aws_launch_template.ecs_lt` | Launch Template | EC2 Launch Template using Amazon Linux 2 ECS-Optimized AMI |
| `aws_autoscaling_group.ecs_asg` | ASG | EC2 Auto Scaling Group deployed across private subnets |
| `aws_ecs_capacity_provider.cloud_design_cp` | Capacity Provider | ECS Capacity Provider with managed target capacity |
| `aws_ecs_cluster_capacity_providers` | Association | Associates Capacity Provider strategy with ECS Cluster |
| `aws_key_pair.my_key` | Key Pair | SSH Public Key Pair for EC2 host access |

---

## Inputs (Variables)

| Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `ecs_execution_role_arn` | `string` | Yes | IAM Role ARN for ECS execution |
| `ecs_instance_profile_name` | `string` | Yes | IAM Instance Profile name for EC2 host instances |
| `ecs_instance_sg_id` | `string` | Yes | Security Group ID applied to EC2 container instances |
| `private_subnet_ids` | `list(string)` | Yes | Private Subnet IDs for EC2 Auto Scaling Group placement |
| `public_subnet_ids` | `list(string)` | Yes | Public Subnet IDs |
| `service_discovery_namespace_arn` | `string` | Yes | AWS Cloud Map Private DNS Namespace ARN for Service Connect |

---

## Outputs

| Name | Description |
| :--- | :--- |
| `cluster_id` | ID of the provisioned ECS Cluster |
| `cluster_name` | Name of the provisioned ECS Cluster |
| `capacity_provider_name` | Name of the custom ECS Capacity Provider |

---

## Usage Example

```hcl
module "ecs" {
  source                          = "./modules/aws/ecs"
  ecs_execution_role_arn          = module.iam.ecs_execution_role_arn
  ecs_instance_profile_name       = module.iam.ecs_instance_profile_name
  ecs_instance_sg_id              = module.ecs_instance_sg.id
  private_subnet_ids              = module.vpc.private_subnet_ids
  public_subnet_ids               = module.vpc.public_subnet_ids
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn
}
```

---

## Best Practices & Requirements

- **SSH Keys**: Ensure SSH key file (`.keys/id_ecs.pub`) is populated or replaced with a secure key management mechanism (e.g. AWS Systems Manager Session Manager).
- **Container Insights**: Kept enabled for real-time memory/CPU metrics in CloudWatch.
- **ASG Capacity**: Adjust `min_size`, `max_size`, and `desired_capacity` according to service resource consumption.
