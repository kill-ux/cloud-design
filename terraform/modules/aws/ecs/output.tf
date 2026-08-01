output "cluster_name" {
  description = "ECS Cluster name for Service Connect"
  value       = aws_ecs_cluster.cloud_design_cluster.name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.cloud_design_cluster.arn
}

output "cluster_id" {
  description = "ECS Cluster Id"
  value       = aws_ecs_cluster.cloud_design_cluster.id
}

output "capacity_provider_name" {
  value = aws_ecs_capacity_provider.cloud_design_cp.name
}

output "service_discovery_namespace_arn" {
  description = "Service Discovery HTTP Namespace ARN for Service Connect"
  value       = var.service_discovery_namespace_arn
}
output "device_name" {
  value = var.device_name
}