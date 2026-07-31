# foundation

The base stack for `cloud-design`: networking, security groups, IAM roles,
container registries, secrets, and the TLS certificate. `workload` depends on
this stack's outputs via remote state, so it must be applied first and its
state must not be destroyed while `workload` exists.

## What this provisions

- **VPC** (`module.vpc`) — `10.0.0.0/16`, 2 public + 2 private subnets across
  2 AZs, an Internet Gateway + public route table, and a private route table
  with **no NAT Gateway**. Instead, private-subnet traffic to AWS services
  goes over VPC endpoints:
  - Interface endpoints: ECR (api + dkr), ECS, ECS telemetry, ECS agent,
    CloudWatch Logs, Secrets Manager
  - Gateway endpoint: S3
  - A Cloud Map private DNS namespace (`local`) for ECS Service Connect
- **Security groups** (`sg.tf`) — one per traffic boundary: API Gateway →
  ALB, ALB → ECS instances, ECS instances (self + ALB), API Gateway app,
  RabbitMQ, inventory app + its DB, billing app + its DB, plus a group for
  the VPC endpoints themselves. These are exported as outputs so `workload`
  can attach services to the right ones.
- **IAM** (`module.iam`) — an ECS EC2 instance role/profile
  (`AmazonEC2ContainerServiceforEC2Role`) and an ECS task execution role
  (`AmazonECSTaskExecutionRolePolicy`) with an inline policy granting
  Service Connect discovery + `secretsmanager:GetSecretValue`.
- **ECR** (`module.ecr`) — five repositories: `inventory-app`, `billing-app`,
  `api-gateway-app`, `rabbitmq`, `postgres-db`. Scan-on-push is enabled;
  `force_delete = true` (no deletion protection).
- **Secrets Manager** (`module.secrets`) — a single secret
  (`cloud-design`) holding RabbitMQ and both databases' credentials as one
  JSON blob, consumed by `workload` via `valueFrom` in task definitions.
- **ACM** (`module.acm`) — a DNS-validated certificate for
  `cloud.hansel.lol`, used later by the API Gateway custom domain in
  `workload`.

## Requirements

- Terraform `>= 1.0`, AWS provider `~> 6.0`
- The S3 backend bucket (`cloud-design-tfstate-969209892845-eu-west-3-an`,
  region `eu-west-3`) must already exist
- Ownership/DNS access for the ACM domain — after `apply`, you must manually
  create the DNS validation CNAME record shown in the `cert_validation_record`
  output before the certificate will validate
- Values for every variable in `variables.tf` (region, VPC CIDR, RabbitMQ
  creds, inventory DB creds, billing DB creds) — copy
  `terraform.tfvars.example` to `terraform.tfvars` and fill in real values

## Deploying

```bash
terraform init
terraform plan
terraform apply
```

Key outputs (`output.tf`) — VPC/subnet IDs, all security group IDs, the IAM
role/profile names, the ECR registry map, the secrets ARN, and the ACM
certificate ARN/validation record — are read by `workload` via
`terraform_remote_state`. Don't rename or remove outputs without updating
`workload/main.tf` accordingly.

## Cost management

Everything here is either free or a small flat/metered cost — the real
compute spend lives in `workload`:

- **VPC interface endpoints** (6 of them: ECR×2, ECS, ECS telemetry, ECS
  agent, Logs, Secrets Manager) each bill hourly plus per-GB data processed.
  This is the trade-off for skipping NAT Gateway — cheaper here because
  traffic is limited to AWS API calls, not general internet egress.
- **S3 gateway endpoint** — free.
- **Secrets Manager** — one secret, roughly $0.40/month plus API call costs.
- **ECR** — free for the first 500 MB/month per repository, then billed per
  GB stored; five repos here, so watch cumulative image size/tag count.
- **ACM public certificate** — free.
- **IAM roles/policies** — free.