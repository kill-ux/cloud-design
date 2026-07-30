# API Gateway
module "api_gateway_service" {
  source = "../modules/aws/ecs_task"

  task_name       = "api-gateway"
  container_image = "${local.ecr_registry["api-gateway-app"]}:1.0.0"
  container_port  = 3000
  port_name       = "api-gateway"
  dns_name        = "api-gateway"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = local.ecs_execution_role_arn
  service_discovery_namespace_arn = local.service_discovery_namespace_arn
  subnets                         = local.private_subnet_ids
  security_groups                 = [local.gateway_sg_id]
  cpu                             = 128
  memory                          = 256
  desired_count                   = 1

  enable_autoscaling = true
  scaling_metric     = "requests"
  target_value       = 1500
  max_capacity       = 2
  target_group_arn   = module.alb.target_group_arn

  alb_arn_suffix              = module.alb.arn_suffix
  alb_target_group_arn_suffix = module.alb.alb_target_group_arn_suffix

  environment_variables = [
    {
      name  = "RABBITMQ_HOST"
      value = module.rabbitmq_service.discovery_name
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
      value = module.billing_service.discovery_name
    },
    {
      name  = "BILLING_APP_PORT"
      value = "8080"
    },
    {
      name  = "INVENTORY_APP_HOST"
      value = module.inventory_service.discovery_name
    },
    {
      name  = "INVENTORY_APP_PORT"
      value = "8080"
    },
    {
      name  = "APIGATEWAY_PORT"
      value = "3000"
    }
  ]


  secrets = [
    {
      name      = "RABBITMQ_USER"
      valueFrom = "${local.secrets_arn}:rabbitmq_user::"
    },
    {
      name      = "RABBITMQ_PASS"
      valueFrom = "${local.secrets_arn}:rabbitmq_password::"
    },
  ]

  depends_on = [module.alb, module.billing_service, module.inventory_service]

  tags = { "Component" = "api" }
}


# RabbitMQ
module "rabbitmq_service" {
  source = "../modules/aws/ecs_task"

  task_name       = "rabbitmq"
  container_image = "${local.ecr_registry["rabbitmq"]}:1.0.0"
  container_port  = 5672
  port_name       = "amqp"
  discovery_name  = "rabbitmq"
  dns_name        = "rabbitmq"


  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = local.ecs_execution_role_arn
  service_discovery_namespace_arn = local.service_discovery_namespace_arn
  subnets                         = local.private_subnet_ids
  security_groups                 = [local.rabbitmq_sg_id]

  cpu           = 128
  memory        = 256
  desired_count = 1

  secrets = [
    {
      name      = "RABBITMQ_USER"
      valueFrom = "${local.secrets_arn}:rabbitmq_user::"
    },
    {
      name      = "RABBITMQ_PASS"
      valueFrom = "${local.secrets_arn}:rabbitmq_password::"
    },
  ]
}


module "inventory_service" {
  source = "../modules/aws/ecs_task"

  task_name       = "inventory"
  container_image = "${local.ecr_registry["inventory-app"]}:1.0.0"
  container_port  = 8080
  port_name       = "inventory"
  discovery_name  = "inventory"
  dns_name        = "inventory"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = local.ecs_execution_role_arn
  service_discovery_namespace_arn = local.service_discovery_namespace_arn
  subnets                         = local.private_subnet_ids
  security_groups                 = [local.inventory_sg_id]

  cpu           = 128
  memory        = 256
  desired_count = 1

  enable_autoscaling = true
  scaling_metric     = "cpu"
  target_value       = 70
  max_capacity       = 2

  secrets = [
    {
      name      = "INVENTORY_DB_USER"
      valueFrom = "${local.secrets_arn}:inventory_db_user::"
    },
    {
      name      = "INVENTORY_DB_PASS"
      valueFrom = "${local.secrets_arn}:inventory_db_password::"
    },
    {
      name      = "INVENTORY_DB_NAME"
      valueFrom = "${local.secrets_arn}:inventory_db_name::"
    },
  ]

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
  ]

  depends_on = [module.inventory_db_service]
}


module "inventory_db_service" {
  source = "../modules/aws/ecs_task"

  task_name       = "inventory-db"
  container_image = "${local.ecr_registry["postgres-db"]}:1.0.0"
  container_port  = 5432
  port_name       = "inventory-db"
  discovery_name  = "inventory-db"
  dns_name        = "inventory-db"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = local.ecs_execution_role_arn
  service_discovery_namespace_arn = local.service_discovery_namespace_arn

  enable_ebs_mounts               = true
  placement_constraint_expression = "attribute:role == ${module.inventory_db_instance.placement_attribute}"

  subnets         = local.private_subnet_ids
  security_groups = [local.inventory_db_sg_id]

  cpu                      = 128
  memory                   = 256
  desired_count            = 1
  enable_distinct_instance = true

  secrets = [
    {
      name      = "DB_USER"
      valueFrom = "${local.secrets_arn}:inventory_db_user::"
    },
    {
      name      = "DB_PASS"
      valueFrom = "${local.secrets_arn}:inventory_db_password::"
    },
    {
      name      = "DB_NAME"
      valueFrom = "${local.secrets_arn}:inventory_db_name::"
    }
  ]

}

module "billing_service" {
  source = "../modules/aws/ecs_task"

  task_name       = "billing"
  container_image = "${local.ecr_registry["billing-app"]}:1.0.0"
  container_port  = 8080
  port_name       = "billing"
  discovery_name  = "billing"
  dns_name        = "billing"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = local.ecs_execution_role_arn
  service_discovery_namespace_arn = local.service_discovery_namespace_arn

  subnets         = local.private_subnet_ids
  security_groups = [local.billing_sg_id]

  cpu           = 128
  memory        = 256
  desired_count = 1

  enable_autoscaling = true
  scaling_metric     = "cpu"
  target_value       = 70
  max_capacity       = 2

  secrets = [
    {
      name      = "BILLING_DB_USER"
      valueFrom = "${local.secrets_arn}:billing_db_user::"
    },
    {
      name      = "BILLING_DB_PASS"
      valueFrom = "${local.secrets_arn}:billing_db_password::"
    },
    {
      name      = "BILLING_DB_NAME"
      valueFrom = "${local.secrets_arn}:billing_db_name::"
    },
    {
      name      = "RABBITMQ_USER"
      valueFrom = "${local.secrets_arn}:rabbitmq_user::"
    },
    {
      name      = "RABBITMQ_PASS"
      valueFrom = "${local.secrets_arn}:rabbitmq_password::"
    },

  ]


  environment_variables = [
    {
      name  = "BILLING_APP_PORT"
      value = "8080"
    },
    {
      name  = "BILLING_DB_HOST"
      value = module.billing_db_service.discovery_name
    },
    {
      name  = "BILLING_DB_PORT"
      value = "5432"
    },
    {
      name  = "RABBITMQ_HOST"
      value = module.rabbitmq_service.discovery_name
    },
    {
      name  = "RABBITMQ_PORT"
      value = "5672"
    },
    {
      name  = "RABBITMQ_QUEUE"
      value = "billing-queue"
    }
  ]

  depends_on = [module.billing_db_service, module.rabbitmq_service]
}


module "billing_db_service" {
  source = "../modules/aws/ecs_task"

  task_name       = "billing-db"
  container_image = "${local.ecr_registry["postgres-db"]}:1.0.0"
  container_port  = 5432
  port_name       = "billing-db"
  discovery_name  = "billing-db"
  dns_name        = "billing-db"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = local.ecs_execution_role_arn
  service_discovery_namespace_arn = local.service_discovery_namespace_arn

  subnets         = local.private_subnet_ids
  security_groups = [local.billing_db_sg_id]

  cpu                      = 128
  memory                   = 256
  desired_count            = 1
  enable_distinct_instance = true

  enable_ebs_mounts               = true
  placement_constraint_expression = "attribute:role == ${module.billing_db_instance.placement_attribute}"

  secrets = [
    {
      name      = "DB_USER"
      valueFrom = "${local.secrets_arn}:billing_db_user::"
    },
    {
      name      = "DB_PASS"
      valueFrom = "${local.secrets_arn}:billing_db_password::"
    },
    {
      name      = "DB_NAME"
      valueFrom = "${local.secrets_arn}:billing_db_name::"
    }
  ]
}

