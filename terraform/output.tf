output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs in the VPC"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs in the VPC"
  value       = module.vpc.private_subnet_ids
}

output "alb_sg_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = module.security.alb_sg_id
}

output "gateway_sg_id" {
  description = "Security group ID for the API Gateway service"
  value       = module.security.gateway_sg_id
}

output "inventory_sg_id" {
  description = "Security group ID for the Inventory service"
  value       = module.security.inventory_sg_id
}

output "billing_sg_id" {
  description = "Security group ID for the Billing service"
  value       = module.security.billing_sg_id
}

output "inventory_db_sg_id" {
  description = "Security group ID for the Inventory Database"
  value       = module.security.inventory_db_sg_id
}

output "billing_db_sg_id" {
  description = "Security group ID for the Billing Database"
  value       = module.security.billing_db_sg_id
}

output "rabbitmq_sg_id" {
  description = "Security group ID for RabbitMQ message queue"
  value       = module.security.rabbitmq_sg_id
}