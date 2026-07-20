# modules/aws/ecs_task/variables.tf

variable "task_name" {
  description = "Name of the ECS task (used as family name)"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image URI"
  type        = string
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "port_name" {
  description = "Port name for Service Connect"
  type        = string
}

variable "cpu" {
  description = "CPU units (256, 512, 1024, etc)"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory in MB (512, 1024, 2048, etc)"
  type        = number
  default     = 512
}

variable "hostname" {
  description = "Hostname of the container"
  type = string
}

variable "execution_role_arn" {
  description = "ARN of ECS task execution role"
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "capacity_provider_name" {
  description = "ECS capacity provider name"
  type        = string
}

variable "subnets" {
  description = "Subnet IDs for the service"
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs"
  type        = list(string)
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "service_discovery_namespace_arn" {
  description = "Service Discovery namespace ARN for Service Connect"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_service_connect" {
  description = "Enable Service Connect for this service"
  type        = bool
  default     = true
}

variable "discovery_name" {
  description = "Service Connect discovery name"
  type        = string
  default     = ""
}

variable "dns_name" {
  description = "DNS name for Service Connect client alias"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}