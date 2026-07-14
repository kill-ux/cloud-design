module "vpc" {
  source = "./modules/aws/vpc"
  vpc_cidr = var.vpc_cidr
}