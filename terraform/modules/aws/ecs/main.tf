resource "aws_ecs_cluster" "cloud_design_cluster" {
  name = "cloud-design-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = { "Name" = "cloud-design-cluster" }
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix = "cloud-design-ecs-"
  image_id = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  vpc_security_group_ids = [ var.ecs_instance_sg_id ]

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=cloud-design-cluster >> /etc/ecs/ecs.config
    EOF
  )

  tags = { "Name" = "cloud-design-ecs-lt" }
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
