output "service_name" {
  value       = aws_ecs_service.service.name
  description = "Name of the ECS service"
}

output "service_arn" {
  value       = aws_ecs_service.service.arn
  description = "ARN of the ECS service"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.task.arn
  description = "ARN of the task definition"
}

output "log_group_name" {
  value       = aws_cloudwatch_log_group.task_logs.name
  description = "CloudWatch log group name"
}

output "discovery_name" {
  value       = var.discovery_name != "" ? var.discovery_name : var.task_name
  description = "Service Connect discovery name"
}

output "container_port" {
  value = var.container_port
}