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

# output "nginx_1_service_name" {
#   description = "Service name for nginx_1 (for Service Connect discovery)"
#   value       = aws_ecs_service.nginx_1.name
# }

# output "nginx_2_service_name" {
#   description = "Service name for nginx_2 (for Service Connect discovery)"
#   value       = aws_ecs_service.nginx_2.name
# }

# output "nginx_1_service_arn" {
#   description = "Service ARN for nginx_1"
#   value       = aws_ecs_service.nginx_1.id
# }

# output "nginx_2_service_arn" {
#   description = "Service ARN for nginx_2"
#   value       = aws_ecs_service.nginx_2.id
# }

output "service_discovery_namespace_arn" {
  description = "Service Discovery HTTP Namespace ARN for Service Connect"
  value       = var.service_discovery_namespace_arn
}

# output "ecs_instance_public_ips" {
#   description = "Public IPs of ECS EC2 instances - SSH into these to test Service Connect"
#   value       = data.aws_instances.ecs_instances.public_ips
# }
