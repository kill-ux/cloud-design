
# ==================== API Gateway Security Group ====================
module "gateway_sg" {
  source = "./modules/aws/security_group"

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

# API Gateway
module "api_gateway_service" {
  source = "./modules/aws/ecs_task"

  task_name       = "api-gateway"
  container_image = "${var.ecr_registry}/api-gateway-app:1.0.0"
  container_port  = 3000
  port_name       = "api-gateway"
  dns_name        = "api-gateway"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = module.iam.ecs_execution_role_arn
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn

  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.gateway_sg.id]
  cpu             = 128
  memory          = 256

  environment_variables = [
    {
      name  = "RABBITMQ_HOST"
      value = "rabbitmq"
    },
    {
      name  = "RABBITMQ_PORT"
      value = "5672"
    },
    {
      name  = "RABBITMQ_QUEUE"
      value = "billing-queue"
    },
    {
      name  = "BILLING_APP_HOST"
      value = "billing" // module.billing_service.discovery_name
    },
    {
      name  = "BILLING_APP_PORT"
      value = "8080"
    },
    {
      name  = "INVENTORY_APP_HOST"
      value = "inventory" // module.inventory_service.discovery_name
    },
    {
      name  = "INVENTORY_APP_PORT"
      value = "8080"
    },
    {
      name  = "APIGATEWAY_PORT"
      value = "3000"
    },
    {
      name  = "RABBITMQ_USER"
      value = var.rabbitmq_user
    },
    {
      name  = "RABBITMQ_PASS"
      value = var.rabbitmq_password
    }
  ]

  tags = { "Component" = "api" }
}

# ==================== RabbitMQ Security Group ====================
module "rabbitmq_sg" {
  source = "./modules/aws/security_group"

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


# RabbitMQ
module "rabbitmq_service" {
  source = "./modules/aws/ecs_task"

  task_name       = "rabbitmq"
  container_image = "${var.ecr_registry}/rabbitmq:1.0.0"
  container_port  = 5672
  port_name       = "amqp"
  discovery_name  = "rabbitmq"
  dns_name        = "rabbitmq"


  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = module.iam.ecs_execution_role_arn
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn

  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.rabbitmq_sg.id]

  cpu    = 128
  memory = 256

  environment_variables = [
    {
      name  = "RABBITMQ_USER"
      value = var.rabbitmq_user
    },
    {
      name  = "RABBITMQ_PASS"
      value = var.rabbitmq_password
    }
  ]
}

# ==================== Inventory App Security Group ====================
module "inventory_sg" {
  source = "./modules/aws/security_group"

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

module "inventory_service" {
  source = "./modules/aws/ecs_task"

  task_name       = "inventory"
  container_image = "${var.ecr_registry}/inventory-app:1.0.0"
  container_port  = 8080
  port_name       = "inventory"
  discovery_name  = "inventory"
  dns_name        = "inventory"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = module.iam.ecs_execution_role_arn
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn

  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.inventory_sg.id]

  cpu    = 128
  memory = 256

  environment_variables = [
    {
      name  = "INVENTORY_APP_PORT"
      value = "8080"
    },
    {
      name  = "INVENTORY_DB_HOST"
      value = module.inventory_db_service.discovery_name
    },
    {
      name  = "INVENTORY_DB_PORT"
      value = "5432"
    },
    {
      name  = "INVENTORY_DB_USER"
      value = var.inventory_db_user
    },
    {
      name  = "INVENTORY_DB_PASS"
      value = var.inventory_db_password
    },
    {
      name  = "INVENTORY_DB_NAME"
      value = var.inventory_db_name
    }
  ]
}

# ==================== Inventory DB Security Group ====================
module "inventory_db_sg" {
  source = "./modules/aws/security_group"

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

module "inventory_db_service" {
  source = "./modules/aws/ecs_task"

  task_name       = "inventory-db"
  container_image = "${var.ecr_registry}/postgres-db:1.0.0"
  container_port  = 5432
  port_name       = "inventory_db"
  discovery_name  = "inventory_db"
  dns_name        = "inventory_db"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = module.iam.ecs_execution_role_arn
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn

  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.inventory_db_sg.id]

  cpu    = 128
  memory = 256


  environment_variables = [
    {
      name  = "DB_USER"
      value = var.inventory_db_user
    },
    {
      name  = "DB_PASS"
      value = var.inventory_db_password
    },
    {
      name  = "DB_NAME"
      value = var.inventory_db_name
    }
  ]

}

# ==================== Billing App Security Group ====================
module "billing_sg" {
  source = "./modules/aws/security_group"

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

module "billing_service" {
  source = "./modules/aws/ecs_task"

  task_name       = "billing"
  container_image = "${var.ecr_registry}/billing-app:1.0.0"
  container_port  = 8080
  port_name       = "billing"
  discovery_name  = "billing"
  dns_name        = "billing"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = module.iam.ecs_execution_role_arn
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn

  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.billing_sg.id]

  cpu    = 128
  memory = 256

   environment_variables = [
    {
      name  = "BILLING_APP_PORT"
      value = "8080"
    },
    {
      name  = "BILLING_DB_HOST"
      value = module.inventory_db_service.discovery_name
    },
    {
      name  = "BILLING_DB_PORT"
      value = "5432"
    },
    {
      name  = "BILLING_DB_USER"
      value = var.billing_db_user
    },
    {
      name  = "INVENTORY_DB_PASS"
      value = var.billing_db_password
    },
    {
      name  = "BILLING_DB_NAME"
      value = var.billing_db_name
    }
  ]
}

# ==================== Billing DB Security Group ====================
module "billing_db_sg" {
  source = "./modules/aws/security_group"

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

module "billing_db_service" {
  source = "./modules/aws/ecs_task"

  task_name       = "billing-db"
  container_image = "${var.ecr_registry}/postgres-db:1.0.0"
  container_port  = 5432
  port_name       = "billing_db"
  discovery_name  = "billing_db"
  dns_name        = "billing_db"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = module.iam.ecs_execution_role_arn
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn

  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.billing_db_sg.id]

  cpu    = 128
  memory = 256

  environment_variables = [
    {
      name  = "DB_USER"
      value = var.billing_db_user
    },
    {
      name  = "DB_PASS"
      value = var.billing_db_password
    },
    {
      name  = "DB_NAME"
      value = var.billing_db_name
    }
  ]
}


# ===== ALB Security Group =====
module "alb_sg" {
  source = "./modules/aws/security_group"

  name        = "alb_sg"
  description = "Allow inbound internet traffic to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "Allow HTTP from internet"
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = { "Component" = "alb" }
}






# ===== ECS Instance Security Group =====
module "ecs_instance_sg" {
  source = "./modules/aws/security_group"

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
    {
      description = "TEMP: Allow SSH for debugging"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  ]

  tags = { "Component" = "compute" }
}
