# workload

The application/compute stack for `cloud-design`: the ECS cluster, all six
services, the ALB, the public-facing API Gateway + Cognito auth, the
monitoring dashboard, and a cost-alert budget. Depends entirely on
`foundation` having already been applied — its VPC, subnets, security
groups, IAM roles, ECR registry, secrets, and ACM cert are pulled in via
`terraform_remote_state`.

## What this provisions

- **ALB** (`module.alb`) — internal Application Load Balancer with an HTTP
  listener on port 80, forwarding to the API Gateway service's target group
  (health check on `/health`).
- **ECS cluster + capacity** (`module.ecs`) — an ECS cluster with Container
  Insights enabled, backed by an EC2 Auto Scaling Group of `t3.micro`
  instances (`desired_capacity = 4`, `min_size = 4`, `max_size = 8`) via a
  managed-scaling capacity provider. Service Connect defaults to the
  `foundation` service-discovery namespace.
- **ECS services** (`services.tf`, via `module.ecs_task`) — six services,
  each pulling its image from the matching `foundation` ECR repo at tag
  `1.0.0`:
  - `api-gateway` — public entry point, autoscales on request count
  - `rabbitmq` — message broker for billing
  - `inventory` — autoscales on CPU, talks to its own DB
  - `inventory-db` — self-hosted Postgres, pinned to a dedicated EC2 host
  - `billing` — autoscales on CPU, talks to RabbitMQ + its own DB
  - `billing-db` — self-hosted Postgres, pinned to a dedicated EC2 host

  All secrets (DB creds, RabbitMQ creds) are injected from the single
  Secrets Manager secret created in `foundation`.
- **Dedicated DB hosts + volumes** (`module.ecs_db_instance`,
  `module.ebs`) — one EC2 instance each for `inventory-db` and `billing-db`
  (tagged with a placement attribute so their ECS tasks land only there),
  each with its own 10 GB `gp3` EBS volume mounted for Postgres data.
- **Cognito + API Gateway** (`module.cognito`) — a Cognito user pool + app
  client, an HTTP API Gateway with a JWT authorizer backed by that pool, a
  VPC Link into the ALB, and a custom domain mapping
  (`cloud.hansel.lol`) using the ACM cert from `foundation`.
- **Dashboard** (`module.dashboard`) — a CloudWatch dashboard showing
  CPU/memory utilization per ECS service.
- **Budget alert** (`aws_budgets_budget.monthly_cost_alert`) — a $50/month
  cost budget that emails when actual spend crosses 80%.

## Requirements

- `foundation` must already be applied (same S3 bucket, `eu-west-3`) — this
  stack reads its state as a `data "terraform_remote_state"` source and will
  fail without it
- Application images pushed to the `foundation`-created ECR repos, tagged
  `1.0.0` (matches `container_image` references in `services.tf`) —
  services won't start otherwise
- Variables filled in (copy `terraform.tfvars.example`): `aws_region`,
  `vpc_cidr` (must match `foundation`'s)
- After apply, point DNS for `cloud.hansel.lol` at the
  `target_domain_name` output so the custom API Gateway domain resolves
- Update the hardcoded budget-alert email in `main.tf`
  (`aws_budgets_budget.monthly_cost_alert`) to an address you actually
  monitor

## Deploying

```bash
terraform init
terraform plan
terraform apply
```

Outputs include the ALB DNS name, Cognito user pool/client IDs, the API
Gateway URL, and the custom domain target — useful for wiring up a frontend
or testing auth flows.

## Cost management

This is where nearly all of the recurring spend lives, and it's what the
$50/month budget alert is watching:

- **EC2 (`t3.micro` × 4–8, via the ASG)** — the dominant cost. The ASG
  floor is `min_size = 4`, so you're paying for 4 running instances even at
  idle; raise/lower `desired_capacity`/`min_size`/`max_size` in `main.tf` to
  trade cost for headroom.
- **ALB** — flat hourly charge plus LCU (load balancer capacity unit)
  usage; one ALB total, shared by all services.
- **EBS** — two 10 GB `gp3` volumes (inventory-db, billing-db) — small,
  a couple dollars/month combined.
- **HTTP API Gateway** — billed per million requests (cheaper tier than
  REST APIs) plus data transfer.
- **Cognito** — free up to 50,000 monthly active users, which this project
  won't come close to.
- **CloudWatch dashboard + Container Insights** — a small flat per-dashboard
  fee plus standard custom-metric ingestion costs from Container Insights.
- **AWS Budget** — free; it's the safety net for everything above.

If you want a cheaper "always cold" setup for occasional use, the two levers
that matter most are the ASG `min_size`/`desired_capacity` (drop toward the
services actually needing to stay up) and whether both DB EC2 hosts need to
run continuously versus being started on demand.