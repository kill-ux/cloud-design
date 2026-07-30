module "aws_gateway_sg" {
  source      = "../modules/aws/security_group"
  name        = "aws_gateway_sg"
  description = "Security group for API Gateway VPC Link"
  vpc_id      = module.vpc.vpc_id

  egress_rules = [
    {
      description = "Allow HTTP outbound to VPC"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_ipv4   = var.vpc_cidr
    }
  ]
}


# ===== ALB Security Group =====
module "alb_sg" {
  source = "../modules/aws/security_group"

  name        = "alb_sg"
  description = "Allow inbound Aws API Gateway  traffic to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description                  = "Allow HTTP from Aws API Gateway "
      from_port                    = 80
      protocol                     = "tcp"
      to_port                      = 80
      referenced_security_group_id = module.aws_gateway_sg.id
    }
  ]

  tags = { "Component" = "alb" }
}

# ===== ECS Instance Security Group =====
module "ecs_instance_sg" {
  source = "../modules/aws/security_group"

  name        = "ecs_instance_sg"
  description = "Security group for ECS EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "Allow Service Connect traffic between ECS services"
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
      self        = true
    },
    {
      description                  = "Allow traffic from ALB"
      from_port                    = 80
      to_port                      = 80
      protocol                     = "tcp"
      referenced_security_group_id = module.alb_sg.id
    },
    # {
    #   description = "TEMP: Allow SSH for debugging"
    #   from_port   = 22
    #   to_port     = 22
    #   protocol    = "tcp"
    #   cidr_ipv4   = "0.0.0.0/0"
    # }
  ]

  tags = { "Component" = "compute" }
}

# ==================== API Gateway Security Group ====================
module "gateway_sg" {
  source = "../modules/aws/security_group"

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

# ==================== RabbitMQ Security Group ====================
module "rabbitmq_sg" {
  source = "../modules/aws/security_group"

  name        = "rabbitmq_sg"
  description = "Allow traffic from applications to RabbitMQ"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description                  = "Allow from API gateway"
      from_port                    = 5672
      to_port                      = 5672
      protocol                     = "tcp"
      referenced_security_group_id = module.gateway_sg.id
    },
    {
      description                  = "Allow from billing"
      from_port                    = 5672
      to_port                      = 5672
      protocol                     = "tcp"
      referenced_security_group_id = module.billing_sg.id
    }
  ]

  tags = { "Component" = "message-broker" }
}

module "inventory_sg" {
  source = "../modules/aws/security_group"

  name        = "inventory_sg"
  description = "Allow traffic from API gateway to inventory app"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description                  = "Allow traffic from API gateway"
      from_port                    = 8080
      protocol                     = "tcp"
      to_port                      = 8080
      referenced_security_group_id = module.gateway_sg.id
    }
  ]

  tags = { "Component" = "inventory" }
}

# ==================== Inventory DB Security Group ====================
module "inventory_db_sg" {
  source = "../modules/aws/security_group"

  name        = "inventory_db_sg"
  description = "Allow traffic from inventory app to database"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description                  = "Allow from inventory app"
      from_port                    = 5432
      to_port                      = 5432
      protocol                     = "tcp"
      referenced_security_group_id = module.inventory_sg.id
    }
  ]

  tags = { "Component" = "database" }
}


# ==================== Billing App Security Group ====================
module "billing_sg" {
  source = "../modules/aws/security_group"

  name        = "billing_sg"
  description = "Allow traffic from API gateway to billing app"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description                  = "Allow traffic from API gateway"
      from_port                    = 8080
      protocol                     = "tcp"
      to_port                      = 8080
      referenced_security_group_id = module.gateway_sg.id
    }
  ]

  tags = { "Component" = "billing" }
}



# ==================== Billing DB Security Group ====================
module "billing_db_sg" {
  source = "../modules/aws/security_group"

  name        = "billing_db_sg"
  description = "Allow traffic from billing app to database"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description                  = "Allow from billing app"
      from_port                    = 5432
      to_port                      = 5432
      protocol                     = "tcp"
      referenced_security_group_id = module.billing_sg.id
    }
  ]

  tags = { "Component" = "database" }
}
