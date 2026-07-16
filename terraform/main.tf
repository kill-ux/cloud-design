module "vpc" {
  source = "./modules/aws/vpc"
  vpc_cidr = var.vpc_cidr
}

module "security" {
  source = "./modules/aws/security"
  vpc_id = module.vpc.vpc_id
}

# module "alb" {
#   source = "./modules/aws/alb"
#   alb_sg_id = module.security.alb_sg_id
#   public_subnet_ids = module.vpc.public_subnet_ids
#   vpc_id = module.vpc.vpc_id
# }

module "ecr" {
  source = "./modules/aws/ecr"
}

module "ecs" {
  source = "./modules/aws/ecs"
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
}