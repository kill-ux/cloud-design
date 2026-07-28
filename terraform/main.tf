module "vpc" {
  source              = "./modules/aws/vpc"
  vpc_cidr            = var.vpc_cidr
  aws_region          = var.aws_region
  vpc_endpoints_sg_id = module.vpc_endpoints_sg.id
}

module "alb" {
  source    = "./modules/aws/alb"
  alb_sg_id = module.alb_sg.id
  # public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
}

module "ecr" {
  source = "./modules/aws/ecr"
}

module "iam" {
  source = "./modules/aws/iam"
}

module "ecs" {
  source                          = "./modules/aws/ecs"
  ecs_execution_role_arn          = module.iam.ecs_execution_role_arn
  ecs_instance_profile_name       = module.iam.ecs_instance_profile_name
  ecs_instance_sg_id              = module.ecs_instance_sg.id
  private_subnet_ids              = module.vpc.private_subnet_ids
  public_subnet_ids               = module.vpc.public_subnet_ids
  desired_capacity                = 4
  min_size                        = 4
  max_size                        = 8
  service_discovery_namespace_arn = module.vpc.service_discovery_namespace_arn
}

module "inventory_db_instance" {
  source                    = "./modules/aws/ecs_db_instance"
  host_name                 = "inventory-db"
  iam_instance_profile_name = module.iam.ecs_instance_profile_name
  security_group_id         = module.ecs_instance_sg.id
  subnet_id                 = module.vpc.private_subnet_ids[0]
  cluster_name              = module.ecs.cluster_name
  device_name               = "sdh"
}

module "inventory_db_volume" {
  source            = "./modules/aws/ebs"
  device_name       = "/dev/sdh"
  availability_zone = module.vpc.private_subnet_azs[0]
  ebs_size          = 10
  ebs_type          = "gp3"
  instance_id       = module.inventory_db_instance.instance_id
  tags              = { Name = "inventory-db-volume" }
}

module "billing_db_instance" {
  source                    = "./modules/aws/ecs_db_instance"
  host_name                 = "billing-db"
  iam_instance_profile_name = module.iam.ecs_instance_profile_name
  security_group_id         = module.ecs_instance_sg.id
  subnet_id                 = module.vpc.private_subnet_ids[0]
  cluster_name              = module.ecs.cluster_name
  device_name               = "sdi"
}

module "billing_db_volume" {
  source            = "./modules/aws/ebs"
  device_name       = "/dev/sdi"
  availability_zone = module.vpc.private_subnet_azs[0]
  ebs_size          = 10
  ebs_type          = "gp3"
  instance_id       = module.billing_db_instance.instance_id
  tags              = { Name = "billing_db_volume" }
}


module "cognito" {
  source             = "./modules/aws/cognito"
  aws_region         = var.aws_region
  alb_dns_name       = module.alb.alb_dns_name
  security_group_id  = module.aws_gateway_sg.id
  private_subnet_ids = [module.vpc.private_subnet_ids[0]]
  alb_listener_arn   = module.alb.alb_listener_arn
}

module "secrets" {
  source            = "./modules/aws/secrets"
  rabbitmq_user     = var.rabbitmq_user
  rabbitmq_password = var.rabbitmq_password

  inventory_db_user     = var.inventory_db_user
  inventory_db_password = var.inventory_db_password
  inventory_db_name     = var.inventory_db_name

  billing_db_user     = var.billing_db_user
  billing_db_password = var.billing_db_password
  billing_db_name     = var.billing_db_name
}
