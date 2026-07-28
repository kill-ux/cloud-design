resource "aws_cloudwatch_dashboard" "ecs_central_dashboard" {
  dashboard_name = "CloudDesign-ECS-Cluster-Health"

  dashboard_body = jsonencode({
    widgets = [
      # CPU Utilization (Top Left)
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title = "ECS Services - CPU Utilization (%)"
          region = data.aws_region.current.region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "api-gateway-service", { "label" = "API Gateway" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "rabbitmq-service", { "label" = "RabbitMQ" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "inventory-service", { "label" = "Inventory" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "inventory-db-service", { "label" = "Inventory DB" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "billing-service", { "label" = "Billing" }],
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "billing-db-service", { "label" = "Billing DB" }]
          ]
        }
      },

      # Memory Utilization (Top Right)
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title = "ECS Services - Memory Utilization (%)"
          region = data.aws_region.current.region
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "api-gateway-service", { "label" = "API Gateway" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "rabbitmq-service", { "label" = "RabbitMQ" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "inventory-service", { "label" = "Inventory" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "inventory-db-service", { "label" = "Inventory DB" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "billing-service5", { "label" = "Billing" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", "billing-db-service", { "label" = "Billing DB" }]
          ]
        }
      }
    ]
  })
}

data "aws_region" "current" {}