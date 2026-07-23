# AWS Security Group Reusable Module

This module manages an AWS **Security Group** along with dynamic **Ingress** and **Egress** rules using AWS VPC security group rule resources (`aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule`).

---

## Resources Created

| Resource | Type | Description |
| :--- | :--- | :--- |
| `aws_security_group.sg` | Security Group | Base security group tied to a specific VPC |
| `aws_vpc_security_group_ingress_rule.ingress` | Ingress Rule | Dynamic array of ingress rules |
| `aws_vpc_security_group_egress_rule.egress` | Egress Rule | Dynamic array of egress rules |

---

## Inputs (Variables)

| Name | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `name` | `string` | **Required** | Security Group Name |
| `description` | `string` | `""` | Description of the Security Group purpose |
| `vpc_id` | `string` | **Required** | VPC ID where security group will be created |
| `ingress_rules` | `list(object)` | `[]` | List of ingress rule definitions |
| `egress_rules` | `list(object)` | Default outbound all (`0.0.0.0/0`) | List of egress rule definitions |
| `tags` | `map(string)` | `{}` | Tags map |

---

## Outputs

| Name | Description |
| :--- | :--- |
| `id` | Security Group ID |
| `arn` | Security Group ARN |

---

## Usage Example

```hcl
module "gateway_sg" {
  source      = "./modules/aws/security_group"
  name        = "gateway_sg"
  description = "Allow traffic from ALB to API gateway app"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description                  = "Allow traffic from ALB"
      from_port                    = 3000
      to_port                      = 3000
      protocol                     = "tcp"
      referenced_security_group_id = module.alb_sg.id
    }
  ]

  tags = { "Component" = "api-gateway" }
}
```

---

## Best Practices & Requirements

- **Avoid 0.0.0.0/0 Ingress**: Restrict inbound access using `referenced_security_group_id` between internal tiers (ALB -> API Gateway -> Microservices -> Databases).
- **Rule Decoupling**: Uses modern `aws_vpc_security_group_ingress_rule` resources to avoid cyclic dependency issues.
