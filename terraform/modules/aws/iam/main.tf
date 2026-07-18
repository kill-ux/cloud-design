resource "aws_iam_role" "ecs_instance_role" {
  name = "cloud-design-ecs-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = { "Name" = "cloud-design-ecs-instance-role" }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "cloud-design-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}


# resource "aws_iam_policy_document" "ecs_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "ecs_execution_role" {
#   name = "cloud-design-ecs-execution-role"
#   assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
# }


# resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
#   role = aws_iam_role.ecs_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
