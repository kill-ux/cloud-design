variable "aws_region" {
  type = string
}

variable "alb_dns_name" {
  description = "The public DNS URL of the Load Balancer"
  type        = string
}

variable "security_group_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_listener_arn" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "cert_arn" {
  type = string
}