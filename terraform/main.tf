module "vpc" {
  source = "./modules/aws/vpc"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source = "./modules/aws/security"
  vpc_id = module.vpc.vpc_id
}