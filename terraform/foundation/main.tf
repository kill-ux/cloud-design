module "vpc_endpoints_sg" {
  source = "../modules/aws/security_group"

  name        = "vpc_endpoints_sg"
  description = "Allow HTTPS from private subnets to VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      description = "Allow HTTPS from VPC"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_ipv4   = var.vpc_cidr
    }
  ]

  tags = { "Name" : "vpc_endpoints_sg" }
}

module "vpc" {
  source              = "../modules/aws/vpc"
  vpc_cidr            = var.vpc_cidr
  aws_region          = var.aws_region
  vpc_endpoints_sg_id = module.vpc_endpoints_sg.id
}

module "iam" {
  source = "../modules/aws/iam"
}

module "ecr" {
  source = "../modules/aws/ecr"
}


module "secrets" {
  source            = "../modules/aws/secrets"
  rabbitmq_user     = var.rabbitmq_user
  rabbitmq_password = var.rabbitmq_password

  inventory_db_user     = var.inventory_db_user
  inventory_db_password = var.inventory_db_password
  inventory_db_name     = var.inventory_db_name

  billing_db_user     = var.billing_db_user
  billing_db_password = var.billing_db_password
  billing_db_name     = var.billing_db_name
}

module "acm" {
  source = "../modules/aws/acm"
  domain_name = "cloud.hansel.lol"
}