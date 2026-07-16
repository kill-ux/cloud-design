resource "aws_ecs_cluster" "cloud_design_cluster" {
  name = "cloud-design-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { "Name" = "cloud-design-cluster" }
}


resource "aws_ecs_task_definition" "api_gateway" {
  family                   = "cloud-design-api-gateway"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = "256" # 0.5
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name  = "api-gateway-app"
      image = "969209892845.dkr.ecr.eu-west-3.amazonaws.com/api-gateway-app:1.0.0"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])

  execution_role_arn = var.ecs_execution_role_arn
}
