output "rabbitmq_credentials_arn" {
  value = aws_secretsmanager_secret.rabbitmq_credentials.arn
}

output "inventory_db_credentials_arn" {
  value = aws_secretsmanager_secret.inventory_db_credentials.arn
}

output "billing_db_credentials_arn" {
  value = aws_secretsmanager_secret.billing_db_credentials.arn
}