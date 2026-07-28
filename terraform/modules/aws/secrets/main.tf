resource "aws_secretsmanager_secret" "cloud_design_credentials" {
  name                    = "cloud-design"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rabbitmq_credentials_val" {
  secret_id = aws_secretsmanager_secret.cloud_design_credentials.id
  secret_string = jsonencode({
    rabbitmq_user     = var.rabbitmq_user
    rabbitmq_password = var.rabbitmq_password

    inventory_db_user     = var.inventory_db_user
    inventory_db_password = var.inventory_db_password
    inventory_db_name     = var.inventory_db_name

    billing_db_user     = var.billing_db_user
    billing_db_password = var.billing_db_password
    billing_db_name     = var.billing_db_name
  })
}
