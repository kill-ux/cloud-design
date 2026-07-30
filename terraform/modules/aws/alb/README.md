# AWS Application Load Balancer (ALB) Module

This module provisions an **internal** AWS Application Load Balancer (ALB), an HTTP listener (port 80), and an IP-target group for routing traffic to the API Gateway ECS service.

> ⚠️ **Note:** this ALB is `internal = true` — it has **no public IP**. It only receives traffic from the API Gateway VPC Link (see the `cognito` module), not directly from the internet. Public entry to the system happens through Cognito/API Gateway, not through this load balancer.

---

## Resources Created

| Resource | Type | Description |
| :--- | :--- | :--- |
| `aws_lb.cloud_design_alb` | Application Load Balancer | Internal load balancer, deployed into **private** subnets |
| `aws_lb_target_group.cloud_design_gateway_tg` | Target Group | Port 3000 (HTTP), `target_type = "ip"` (required for awsvpc-mode ECS tasks — instance-type targets won't work) |
| `aws_lb_listener.alb_listener` | LB Listener | Listener on port 80 forwarding to the target group |

---

## Inputs (Variables)

| Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `alb_sg_id` | `string` | Yes | Security group ID attached to the ALB |
| `private_subnet_ids` | `list(string)` | Yes | Private subnet IDs the ALB is deployed into (internal ALB — **not** public subnets) |
| `vpc_id` | `string` | Yes | VPC ID where the target group resides |

---

## Outputs

| Name | Description |
| :--- | :--- |
| `alb_dns_name` | Internal DNS name of the ALB (used by Cognito's API Gateway integration, not by browsers directly) |
| `target_group_arn` | ARN of the API Gateway target group, passed into `ecs_task` as `target_group_arn` to attach the gateway service |
| `arn_suffix` | Short ARN suffix of the ALB itself (`app/...`) — required by CloudWatch/Application Auto Scaling `ALBRequestCountPerTarget` metrics, **not** the same as the full ARN |
| `alb_target_group_arn_suffix` | Short ARN suffix of the target group — combined with `arn_suffix` to form the `resource_label` used for request-count-based autoscaling in `ecs_task` |
| `alb_listener_arn` | ARN of the HTTP listener — consumed by the `cognito` module's HTTP_PROXY integration (`integration_uri`) |

---

## Usage Example

```hcl
module "alb" {
  source             = "./modules/aws/alb"
  alb_sg_id          = module.alb_sg.id
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
}
```

---

## Confusing bits, explained

- **`arn_suffix` vs the ALB's ARN**: AWS's `ALBRequestCountPerTarget` predefined autoscaling metric doesn't accept full ARNs — it wants a `resource_label` built from the *suffix* portion of both the load balancer ARN and target group ARN, joined with `/`. That's the only reason both `arn_suffix` and `alb_target_group_arn_suffix` exist as separate outputs.
- **Why internal, not internet-facing**: all public traffic is meant to terminate at API Gateway (with Cognito JWT auth) first. The ALB only exists to front the ECS `api-gateway` service so API Gateway's VPC Link has a stable target inside the VPC.

---

## Best Practices & Requirements

- **Multi-AZ Availability**: Ensure `private_subnet_ids` includes at least two subnets in separate Availability Zones.
- **Health Check Path**: The target group expects `/health` on port 3000 to return HTTP status `200`.
