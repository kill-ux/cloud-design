
# API Gateway
module "api_gateway_service" {
  source = "./modules/aws/ecs_task"

  task_name       = "api-gateway"
  container_name  = "api-gateway-app"
  hostname        = "api-gateway-app"
  container_image = "${var.ecr_registry}/api-gateway-app:1.0.0"
  container_port  = 3000
  port_name       = "api-gateway"

  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = module.iam.ecs_execution_role_arn
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn

  subnets         = module.vpc.public_subnet_ids
  security_groups = [ module.security.gateway_sg_id ]

  environment_variables = [
    {
      name  = "RABBITMQ_HOST"
      value = module.rabbitmq_service.discovery_name
    },
    {
      name  = "INVENTORY_APP_HOST"
      value = "inventory-app" // just for test
    },
    {
      name  = "BILLING_APP_HOST"
      value = "billing-app"
    }
  ]

  tags = { "Component" = "api" }
}


# RabbitMQ
module "rabbitmq_service" {
  source = "./modules/aws/ecs_task"

  task_name       = "rabbitmq"
  container_name  = "rabbitmq"
  container_image = "${var.ecr_registry}/rabbitmq"
  container_port  = 5672
  port_name       = "amqp"
  hostname        = "rabbitmq"


  cluster_id                      = module.ecs.cluster_id
  cluster_name                    = module.ecs.cluster_name
  capacity_provider_name          = module.ecs.capacity_provider_name
  execution_role_arn              = module.iam.ecs_execution_role_arn
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn

  subnets         = module.vpc.public_subnet_ids
  security_groups = [module.security.rabbitmq_sg_id]

  environment_variables = [
    {
      name  = "RABBITMQ_USER"
      value = "rabbit"
    },
    {
      name  = "RABBITMQ_PASS"
      value = "password"
    }
  ]
}
