module "vpc" {
  source              = "./modules/aws/vpc"
  vpc_cidr            = var.vpc_cidr
  aws_region          = var.aws_region
  vpc_endpoints_sg_id = module.vpc_endpoints_sg.id
}

module "alb" {
  source = "./modules/aws/alb"
  alb_sg_id = module.alb_sg.id
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id = module.vpc.vpc_id
}

module "ecr" {
  source = "./modules/aws/ecr"
}

module "iam" {
  source = "./modules/aws/iam"
}

module "ecs" {
  source                    = "./modules/aws/ecs"
  ecs_execution_role_arn    = module.iam.ecs_execution_role_arn
  ecs_instance_profile_name = module.iam.ecs_instance_profile_name
  ecs_instance_sg_id        = module.ecs_instance_sg.id
  private_subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  desired_capacity = 6
  min_size = 6
  max_size = 12
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn
}
