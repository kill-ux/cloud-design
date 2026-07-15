resource "aws_ecs_cluster" "cloud_design_cluster" {
  name = "cloud-design-cluster"

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  tags = { "Name" = "cloud-design-cluster" }
}