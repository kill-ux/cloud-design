variable "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  type        = string
}

variable "ecs_instance_profile_name" {
  description = "Name of the ECS instance profile"
  type        = string
}
variable "ecs_instance_sg_id" {
  description = "SG for EC2"
  type        = string
}
variable "private_subnet_ids" {
  description = "Private subnets ids for autoscaling group"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnets ids for autoscaling group just for test nginx"
  type        = list(string)
}

# variable "nginx_sd_1" {
#   description = "Service discovery service name for nginx"
#   type        = string
# }

# variable "nginx_sd_2" {
#   description = "Service discovery service name for nginx"
#   type        = string
# }

variable "service_discovery_namespace_arn" {
  description = "ARN of Service Discovery HTTP namespace"
  type        = string
}