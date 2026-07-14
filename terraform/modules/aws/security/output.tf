output "alb_sg_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.alb_sg.id
}

output "gateway_sg_id" {
  description = "Security group ID for the API Gateway service"
  value       = aws_security_group.gateway_sg.id
}

output "inventory_sg_id" {
  description = "Security group ID for the Inventory service"
  value       = aws_security_group.inventory_sg.id
}

output "billing_sg_id" {
  description = "Security group ID for the Billing service"
  value       = aws_security_group.billing_sg.id
}

output "inventory_db_sg_id" {
  description = "Security group ID for the Inventory Database"
  value       = aws_security_group.inventory_db_sg.id
}

output "billing_db_sg_id" {
  description = "Security group ID for the Billing Database"
  value       = aws_security_group.billing_db_sg.id
}

output "rabbitmq_sg_id" {
  description = "Security group ID for RabbitMQ message queue"
  value       = aws_security_group.rabbitmq_sg.id
}
