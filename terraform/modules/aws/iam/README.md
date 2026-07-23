# AWS IAM Roles & Instance Profiles Module

This module provisions **IAM Roles**, **Instance Profiles**, and **Policy Attachments** for ECS container instances and ECS task execution.

---

## Resources Created

| Resource | Type | Description |
| :--- | :--- | :--- |
| `aws_iam_role.ecs_instance_role` | IAM Role | Role assumed by EC2 container instances |
| `aws_iam_role_policy_attachment.ecs_instance_policy` | Policy Attachment | Attaches `AmazonEC2ContainerServiceforEC2Role` |
| `aws_iam_instance_profile.ecs_instance_profile` | Instance Profile | Profile passed to EC2 launch templates |
| `aws_iam_role.ecs_execution_role` | IAM Role | Role assumed by ECS Agent (`ecs-tasks.amazonaws.com`) |
| `aws_iam_role_policy_attachment.ecs_execution_policy` | Policy Attachment | Attaches `AmazonECSTaskExecutionRolePolicy` for ECR & CloudWatch logs |
| `aws_iam_role_policy.ecs_task_service_connect_policy` | Inline Policy | Policy granting Cloud Map / Service Connect discovery permissions |

---

## Outputs

| Name | Description |
| :--- | :--- |
| `ecs_execution_role_arn` | ARN of the ECS Task Execution Role |
| `ecs_instance_profile_name` | Name of the EC2 Instance Profile |

---

## Usage Example

```hcl
module "iam" {
  source = "./modules/aws/iam"
}
```

---

## Best Practices & Requirements

- **Principle of Least Privilege**: Limit `Resource = "*"` wildcard grants when attaching custom policies where specific resource ARNs (like Secrets Manager ARNs) are available.
