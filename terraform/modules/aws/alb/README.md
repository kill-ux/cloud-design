# AWS Application Load Balancer (ALB) Module

This module provisions an AWS **Application Load Balancer (ALB)**, a default HTTP listener (port 80), and an IP-target group configured for routing traffic to backend containers (e.g., API Gateway).

---

## Resources Created

| Resource | Type | Description |
| :--- | :--- | :--- |
| `aws_lb.cloud_design_alb` | Application Load Balancer | Public Internet-facing Load Balancer |
| `aws_lb_target_group.cloud_design_gateway_tg` | Target Group | Target group on port 3000 (HTTP) for IP targets |
| `aws_lb_listener.name` | LB Listener | Listener on port 80 forwarding to the target group |

---

## Inputs (Variables)

| Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `alb_sg_id` | `string` | Yes | Security group ID attached to the ALB |
| `public_subnet_ids` | `list(string)` | Yes | List of public subnet IDs for multi-AZ deployment |
| `vpc_id` | `string` | Yes | VPC ID where target group resides |

---

## Outputs

| Name | Description |
| :--- | :--- |
| `alb_dns_name` | Public DNS name of the Application Load Balancer |
| `target_group_arn` | ARN of the API Gateway target group |

---

## Usage Example

```hcl
module "alb" {
  source            = "./modules/aws/alb"
  alb_sg_id         = module.alb_sg.id
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
}
```

---

## Best Practices & Requirements

- **HTTPS / SSL Termination**: For production deployments, attach an ACM SSL Certificate and change listener protocol from `HTTP:80` to `HTTPS:443`.
- **Multi-AZ Availability**: Ensure `public_subnet_ids` includes at least two subnets in separate Availability Zones.
- **Health Check Path**: The target group expects `/health` on port 3000 to return HTTP status `200`.
