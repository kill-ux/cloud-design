variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (must match the foundation stack)"
  type        = string
}

variable "ecr_registry" {
  description = "ECR registry URL (account ID + region, e.g. 123456789012.dkr.ecr.eu-west-3.amazonaws.com)"
  type        = string
}