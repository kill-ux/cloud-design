resource "aws_secretsmanager_secret" "rabbitmq_credentials" {
  name                    = "cloud-design/rabbitmq"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rabbitmq_credentials_val" {
  secret_id = aws_secretsmanager_secret.rabbitmq_credentials.id
  secret_string = jsonencode({
    username = var.rabbitmq_user
    password = var.rabbitmq_password
  })
}


resource "aws_secretsmanager_secret" "inventory_db_credentials" {
  name                    = "cloud-design/inventory_db"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "inventory_db_credentials_val" {
  secret_id = aws_secretsmanager_secret.inventory_db_credentials.id
  secret_string = jsonencode({
    username = var.inventory_db_user
    password = var.inventory_db_password
    db_name  = var.inventory_db_name
  })
}


resource "aws_secretsmanager_secret" "billing_db_credentials" {
  name                    = "cloud-design/billing_db"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "billing_db_credentials_val" {
  secret_id = aws_secretsmanager_secret.billing_db_credentials.id
  secret_string = jsonencode({
    username = var.billing_db_user
    password = var.billing_db_password
    db_name  = var.billing_db_name
  })
}

