terraform {
  required_version = ">= 1"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
    access_key = var.aws_access_key_id
    secret_key = var.aws_secret_access_key
}