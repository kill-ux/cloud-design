
# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "task_logs" {
  name              = "/ecs/${var.task_name}"
  retention_in_days = var.log_retention_days
  tags              = merge(var.tags, { "Name" = "${var.task_name}-logs" })
}

# Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = var.task_name
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      hostname  = var.hostname
      portMappings = [
        {
          name          = var.port_name
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = var.environment_variables
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.task_logs.name
          "awslogs-region"        = data.aws_region.current.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, { "Name" = "${var.task_name}-task-def" })
}


# ECS Service
resource "aws_ecs_service" "service" {
  name                               = "${var.task_name}-service"
  cluster                            = var.cluster_id
  task_definition                    = aws_ecs_task_definition.task.arn
  desired_count                      = var.desired_count
  force_new_deployment               = true
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  availability_zone_rebalancing      = "DISABLED"

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider_name
    weight            = 100
    base              = 0
  }

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
  }

  dynamic "service_connect_configuration" {
    for_each = var.enable_service_connect ? [1] : []
    content {
      enabled   = true
      namespace = var.service_discovery_namespace_arn
      service {
        discovery_name = var.discovery_name != "" ? var.discovery_name : var.task_name
        port_name      = var.port_name
        client_alias {
          port     = var.container_port
          dns_name = var.dns_name != "" ? var.dns_name : var.task_name
        }
      }
    }
  }

  tags = merge(var.tags, { "Name" = "${var.task_name}-service" })

  depends_on = [aws_cloudwatch_log_group.task_logs, aws_ecs_task_definition.task]
}

# Data source for current region
data "aws_region" "current" {}
