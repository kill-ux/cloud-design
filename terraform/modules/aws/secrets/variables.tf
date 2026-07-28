variable "rabbitmq_user" {
  description = "RabbitMQ username"
  type        = string
  sensitive   = true
}

variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
}

variable "inventory_db_user" {
  description = "Inventory DB username"
  type        = string
  sensitive   = true
}

variable "inventory_db_password" {
  description = "Inventory DB password"
  type        = string
  sensitive   = true
}

variable "inventory_db_name" {
  description = "Inventory DB name"
  type        = string
}


variable "billing_db_user" {
  description = "billing DB username"
  type        = string
  sensitive   = true
}

variable "billing_db_password" {
  description = "billing DB password"
  type        = string
  sensitive   = true
}

variable "billing_db_name" {
  description = "billing DB name"
  type        = string
}

