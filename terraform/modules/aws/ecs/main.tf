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

resource "aws_key_pair" "my_key" {
  key_name   = "my-ecs-key"
  public_key = file(".keys/id_ecs.pub")
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "cloud-design-ecs-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  vpc_security_group_ids = [var.ecs_instance_sg_id]

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=cloud-design-cluster >> /etc/ecs/ecs.config
    EOF
  )

  key_name = aws_key_pair.my_key.key_name

  tags = { "Name" = "cloud-design-ecs-lt" }
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "cloud-design-ecs-asg"
  desired_capacity    = 2 #0
  min_size            = 2 #0
  max_size            = 3 #0
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "cloud-design-ecs-instance"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [ tag ]
  }
}

resource "aws_ecs_capacity_provider" "cloud_design_cp" {
  name = "cloud-design-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cloud_design_cp_assoc" {
  cluster_name       = aws_ecs_cluster.cloud_design_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.cloud_design_cp.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cloud_design_cp.name
    weight            = 100
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([
    {
      name      = "nginx-ctr"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "ENV_VAR", value = "value" }
      ]
    }
  ])
}

resource "aws_ecs_service" "nginx_1" {
  name = "nginx_service_1"
  cluster = aws_ecs_cluster.cloud_design_cluster.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count = 1 #0
  force_new_deployment = true

  network_configuration {
    subnets = var.public_subnet_ids
    security_groups = [ var.ecs_instance_sg_id ]
  }

  service_registries {
    registry_arn = var.nginx_sd_1
  }

  depends_on = [ aws_ecs_cluster_capacity_providers.cloud_design_cp_assoc ]
}

resource "aws_ecs_service" "nginx_2" {
  name = "nginx_service_2"
  cluster = aws_ecs_cluster.cloud_design_cluster.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count = 1 #0
  force_new_deployment = true

  network_configuration {
    subnets = var.public_subnet_ids
    security_groups = [ var.ecs_instance_sg_id ]
  }

  service_registries {
    registry_arn = var.nginx_sd_2
  }


  depends_on = [ aws_ecs_cluster_capacity_providers.cloud_design_cp_assoc ]
}

# resource "aws_ecs_task_definition" "api_gateway" {
#   family                   = "cloud-design-api-gateway"
#   requires_compatibilities = ["EC2"]
#   network_mode             = "awsvpc"
#   cpu                      = "256" # 0.5
#   memory                   = "512"

#   container_definitions = jsonencode([
#     {
#       name  = "api-gateway-app"
#       image = "969209892845.dkr.ecr.eu-west-3.amazonaws.com/api-gateway-app:1.0.0"
#       portMappings = [
#         {
#           containerPort = 3000
#           hostPort      = 3000
#           protocol      = "tcp"
#         }
#       ]
#     }
#   ])

#   execution_role_arn = var.ecs_execution_role_arn
# }
