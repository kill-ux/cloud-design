# AWS VPC & Networking Module

This module provisions a multi-AZ **Virtual Private Cloud (VPC)**, public subnets, private subnets, Internet Gateways, Route Tables, AWS Cloud Map Service Discovery Namespace, and **VPC Interface & Gateway Endpoints** (`s3`, `ecr.api`, `ecr.dkr`, `ecs`, `ecs-agent`, `ecs-telemetry`, `logs`).

---

## Resources Created

| Resource | Type | Description |
| :--- | :--- | :--- |
| `aws_vpc.cloud-design-vpc` | VPC | Primary VPC container with DNS hostnames enabled |
| `aws_subnet.public` | Subnets (Multi-AZ) | Public subnets with auto-assigned public IPv4 addresses |
| `aws_subnet.private` | Subnets (Multi-AZ) | Private subnets for application workloads & databases |
| `aws_internet_gateway.gw` | Internet Gateway | IGW attaching VPC to public internet |
| `aws_route_table.rt` / `private_rt` | Route Tables | Public & private subnet routing tables |
| `aws_service_discovery_private_dns_namespace.local` | Service Discovery | Private DNS namespace (`.local`) for Cloud Map / Service Connect |
| `aws_vpc_endpoint.*` | VPC Endpoints | Private Interface & Gateway endpoints for S3, ECR, ECS, and CloudWatch |

---

## Inputs (Variables)

| Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `vpc_cidr` | `string` | Yes | CIDR block for VPC (e.g. `10.0.0.0/16`) |
| `aws_region` | `string` | Yes | AWS deployment region |
| `vpc_endpoints_sg_id` | `string` | Yes | Security Group ID attached to Interface VPC Endpoints |

---

## Outputs

| Name | Description |
| :--- | :--- |
| `vpc_id` | Provisioned VPC ID |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `service_discovery_namespace_arn` | ARN of the Cloud Map private DNS namespace |

---

## Usage Example

```hcl
module "vpc" {
  source              = "./modules/aws/vpc"
  vpc_cidr            = var.vpc_cidr
  aws_region          = var.aws_region
  vpc_endpoints_sg_id = module.vpc_endpoints_sg.id
}
```

---

## Best Practices & Requirements

- **VPC Endpoints Cost & Security**: Interface endpoints allow containers in private subnets without public IPs or NAT Gateways to securely access AWS services (ECR, S3, CloudWatch Logs).
- **DNS Resolution**: `enable_dns_support` and `enable_dns_hostnames` must remain set to `true` for Cloud Map and Interface VPC endpoint private DNS resolution.
