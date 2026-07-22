variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_endpoints_sg_id" {
  description = "Vpc endpoints sg id"
  type = string
}