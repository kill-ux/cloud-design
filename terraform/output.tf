# output "vpc_id" {
#   description = "The ID of the VPC"
#   value       = module.vpc.vpc_id
# }

# output "public_subnet_ids" {
#   description = "List of public subnet IDs in the VPC"
#   value       = module.vpc.public_subnet_ids
# }

# output "private_subnet_ids" {
#   description = "List of private subnet IDs in the VPC"
#   value       = module.vpc.private_subnet_ids
# }

# output "alb_sg_id" {
#   description = "Security_security_group group ID for the Application Load Balancer"
#   value       = module.security_group.alb_sg_id
# }

# output "gateway_sg_id" {
#   description = "Security_security_group group ID for the API Gateway service"
#   value       = module.security_group.gateway_sg_id
# }

# output "inventory_sg_id" {
#   description = "Security_security_group group ID for the Inventory service"
#   value       = module.security_group.inventory_sg_id
# }

# output "billing_sg_id" {
#   description = "Security_security_group group ID for the Billing service"
#   value       = module.security_group.billing_sg_id
# }

# output "inventory_db_sg_id" {
#   description = "Security_security_group group ID for the Inventory Database"
#   value       = module.security_group.inventory_db_sg_id
# }

# output "billing_db_sg_id" {
#   description = "Security_security_group group ID for the Billing Database"
#   value       = module.security_group.billing_db_sg_id
# }

# output "rabbitmq_sg_id" {
#   description = "Security_security_group group ID for RabbitMQ message queue"
#   value       = module.security_group.rabbitmq_sg_id
# }

# # ========================================
# # SERVICE CONNECT OUTPUTS
# # ========================================

# output "cluster_name" {
#   description = "ECS Cluster name for Service Connect"
#   value       = module.ecs.cluster_name
# }

# output "cluster_arn" {
#   description = "ECS Cluster ARN"
#   value       = module.ecs.cluster_arn
# }

# output "service_discovery_namespace_arn" {
#   description = "Service Discovery HTTP Namespace ARN for Service Connect"
#   value       = module.ecs.service_discovery_namespace_arn
# }

# # output "nginx_1_service_name" {
# #   description = "Service name for nginx_1 - use this to access via Service Connect: nginx_1:80"
# #   value       = module.ecs.nginx_1_service_name
# # }

# # output "nginx_2_service_name" {
# #   description = "Service name for nginx_2 - use this to access via Service Connect: nginx_2:80"
# #   value       = module.ecs.nginx_2_service_name
# # }

# # output "nginx_1_service_arn" {
# #   description = "Service ARN for nginx_1"
# #   value       = module.ecs.nginx_1_service_arn
# # }

# # output "nginx_2_service_arn" {
# #   description = "Service ARN for nginx_2"
# #   value       = module.ecs.nginx_2_service_arn
# # }

# # output "service_connect_dns_names" {
# #   description = "DNS names to use for Service Connect discovery within the cluster"
# #   value = {
# #     nginx_1 = "nginx_1:80"
# #     nginx_2 = "nginx_2:80"
# #   }
# # }

# output "ecs_instance_public_ips" {
#   description = "Public IPs of ECS EC2 instances - SSH into these to test Service Connect"
#   value       = module.ecs.ecs_instance_public_ips
# }

output "alb_dns_name" {
  description = "The public DNS URL of the Load Balancer"
  value       = module.alb.alb_dns_name
}
