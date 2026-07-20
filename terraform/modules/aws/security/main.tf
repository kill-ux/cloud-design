# ---------------------------------------------------------------------------
# ALB
# ---------------------------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow inbound internet traffic to ALB"
  vpc_id      = var.vpc_id

  tags = { "Name" = "cloud-design-alb-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP from internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# ---------------------------------------------------------------------------
# GATEWAY
# ---------------------------------------------------------------------------

resource "aws_security_group" "gateway_sg" {
  name        = "gateway_sg"
  description = "Allow traffic from ALB to API gateway app"
  vpc_id      = var.vpc_id

  tags = { "Name" = "cloud-design-gateway-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "gateway_from_alb" {
  security_group_id            = aws_security_group.gateway_sg.id
  description                  = "Allow traffic from ALB"
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 3000
  to_port                      = 3000
  ip_protocol                  = "tcp"
}

# ---------------------------------------------------------------------------
# INVENTORY APP
# ---------------------------------------------------------------------------

resource "aws_security_group" "inventory_sg" {
  name        = "inventory_sg"
  description = "Allow traffic from API gateway app to inventory app"
  vpc_id      = var.vpc_id

  tags = { "Name" = "cloud-design-inventory-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "inventory_from_gateway" {
  security_group_id            = aws_security_group.inventory_sg.id
  description                  = "Allow traffic from API gateway"
  referenced_security_group_id = aws_security_group.gateway_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# ---------------------------------------------------------------------------
# BILLING APP
# ---------------------------------------------------------------------------

resource "aws_security_group" "billing_sg" {
  name        = "billing_sg"
  description = "Allow traffic from API gateway to billing app"
  vpc_id      = var.vpc_id

  tags = { "Name" = "cloud-design-billing-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "billing_from_gateway" {
  security_group_id            = aws_security_group.billing_sg.id
  description                  = "Allow traffic from API gateway"
  referenced_security_group_id = aws_security_group.gateway_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# ---------------------------------------------------------------------------
# RABBITMQ
# ---------------------------------------------------------------------------

resource "aws_security_group" "rabbitmq_sg" {
  name        = "rabbitmq_sg"
  description = "Allow traffic from API gateway to rabbitmq"
  vpc_id      = var.vpc_id

  tags = { "Name" = "cloud-design-rabbitmq" }
}

resource "aws_vpc_security_group_ingress_rule" "rabbitmq_rules" {
  for_each = {
    gateway = aws_security_group.gateway_sg.id
    billing = aws_security_group.billing_sg.id
  }

  security_group_id            = aws_security_group.rabbitmq_sg.id
  description                  = "Allow traffic from ${each.key}"
  referenced_security_group_id = each.value
  from_port                    = 5672
  to_port                      = 5672
  ip_protocol                  = "tcp"

  tags = { "Name" = "cloud-design-rabbitmq-from-${each.key}" }
}

# ---------------------------------------------------------------------------
# BILLING DB
# ---------------------------------------------------------------------------

resource "aws_security_group" "billing_db_sg" {
  name        = "billing_db_sg"
  description = "Allow traffic from billing app to billing db"
  vpc_id      = var.vpc_id
  tags        = { "Name" = "cloud-design-billing-db-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "billing_db_from_billing_app" {
  security_group_id            = aws_security_group.billing_db_sg.id
  description                  = "Allow traffic from billing app"
  referenced_security_group_id = aws_security_group.billing_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# ---------------------------------------------------------------------------
# INVENTORY DB
# ---------------------------------------------------------------------------

resource "aws_security_group" "inventory_db_sg" {
  name        = "inventory_db_sg"
  description = "Allow traffic from inventory app to inventory db"
  vpc_id      = var.vpc_id
  tags        = { "Name" = "cloud-design-inventory-db-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "inventory_db_from_inventory_app" {
  security_group_id            = aws_security_group.inventory_db_sg.id
  description                  = "Allow traffic from inventory app"
  referenced_security_group_id = aws_security_group.inventory_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# ---------------------------------------------------------------------------
# Egrees for all
# ---------------------------------------------------------------------------

locals {
  security_groups = {
    alb          = aws_security_group.alb_sg.id
    gateway      = aws_security_group.gateway_sg.id
    inventory    = aws_security_group.inventory_sg.id
    billing      = aws_security_group.billing_sg.id
    inventory_db = aws_security_group.inventory_db_sg.id
    billing_db   = aws_security_group.billing_db_sg.id
    rabbitmq     = aws_security_group.rabbitmq_sg.id
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_out" {
  for_each = local.security_groups

  security_group_id = each.value
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------------------------------------------------------------------------
# ECS INSTENCE
# ---------------------------------------------------------------------------

resource "aws_security_group" "ecs_instance_sg" {
  name        = "ecs_instance_sg"
  description = "Security group for ECS EC2 instances (bridge mode testing)"
  vpc_id      = var.vpc_id

  tags = { "Name" = "cloud-design-ecs-instance-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_service_connect" {
  security_group_id = aws_security_group.ecs_instance_sg.id
  description       = "Allow Service Connect traffic between ECS services"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  referenced_security_group_id = aws_security_group.ecs_instance_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "ecs_instance_from_alb" {
  security_group_id            = aws_security_group.ecs_instance_sg.id
  description                  = "Allow traffic from ALB"
  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_instance_http_temp" {
  security_group_id = aws_security_group.ecs_instance_sg.id
  description         = "TEMP: Allow HTTP from anywhere for testing - REMOVE AFTER"
  cidr_ipv4           = "0.0.0.0/0"
  from_port           = 80
  to_port             = 80
  ip_protocol         = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_instance_ssh_temp" {
  security_group_id = aws_security_group.ecs_instance_sg.id
  description         = "TEMP: Allow SSH for debugging"
  cidr_ipv4           = "0.0.0.0/0"
  from_port           = 22
  to_port             = 22
  ip_protocol         = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_instance_all_out" {
  security_group_id = aws_security_group.ecs_instance_sg.id
  description        = "Allow all outbound"
  cidr_ipv4          = "0.0.0.0/0"
  ip_protocol         = "-1"
}
