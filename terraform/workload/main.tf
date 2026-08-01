data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = "cloud-design-tfstate-969209892845-eu-west-3-an"
    key    = "foundation/terraform.tfstate"
    region = "eu-west-3"
  }

}

locals {
  vpc_id                          = data.terraform_remote_state.foundation.outputs.vpc_id
  private_subnet_ids              = data.terraform_remote_state.foundation.outputs.private_subnet_ids
  public_subnet_ids               = data.terraform_remote_state.foundation.outputs.public_subnet_ids
  ecs_execution_role_arn          = data.terraform_remote_state.foundation.outputs.ecs_execution_role_arn
  ecs_instance_profile_name       = data.terraform_remote_state.foundation.outputs.ecs_instance_profile_name
  service_discovery_namespace_arn = data.terraform_remote_state.foundation.outputs.service_discovery_namespace_arn
  private_subnet_azs              = data.terraform_remote_state.foundation.outputs.private_subnet_azs
  secrets_arn                     = data.terraform_remote_state.foundation.outputs.secrets_arn
  ecr_registry                    = data.terraform_remote_state.foundation.outputs.ecr_registry

  aws_gateway_sg_id  = data.terraform_remote_state.foundation.outputs.aws_gateway_sg_id
  alb_sg_id          = data.terraform_remote_state.foundation.outputs.alb_sg_id
  ecs_instance_sg_id = data.terraform_remote_state.foundation.outputs.ecs_instance_sg_id
  gateway_sg_id      = data.terraform_remote_state.foundation.outputs.gateway_sg_id
  rabbitmq_sg_id     = data.terraform_remote_state.foundation.outputs.rabbitmq_sg_id
  inventory_sg_id     = data.terraform_remote_state.foundation.outputs.inventory_sg_id
  inventory_db_sg_id     = data.terraform_remote_state.foundation.outputs.inventory_db_sg_id
  billing_sg_id     = data.terraform_remote_state.foundation.outputs.billing_sg_id
  billing_db_sg_id     = data.terraform_remote_state.foundation.outputs.billing_db_sg_id

  cert_arn = data.terraform_remote_state.foundation.outputs.cert_arn
}

module "alb" {
  source             = "../modules/aws/alb"
  alb_sg_id          = local.alb_sg_id
  private_subnet_ids = local.private_subnet_ids
  vpc_id             = local.vpc_id
}

module "ecs" {
  source                          = "../modules/aws/ecs"
  ecs_execution_role_arn          = local.ecs_execution_role_arn
  ecs_instance_profile_name       = local.ecs_instance_profile_name
  ecs_instance_sg_id              = local.ecs_instance_sg_id
  private_subnet_ids              = local.private_subnet_ids
  public_subnet_ids               = local.public_subnet_ids
  desired_capacity                = 4
  min_size                        = 4
  max_size                        = 8
  service_discovery_namespace_arn = local.service_discovery_namespace_arn
}

module "inventory_db_instance" {
  source                    = "../modules/aws/ecs_db_instance"
  host_name                 = "inventory-db"
  iam_instance_profile_name = local.ecs_instance_profile_name
  security_group_id         = local.ecs_instance_sg_id
  subnet_id                 = local.private_subnet_ids[0]
  cluster_name              = module.ecs.cluster_name
  device_name               = "sdh"
}

module "inventory_db_volume" {
  source            = "../modules/aws/ebs"
  device_name       = "/dev/sdh"
  availability_zone = local.private_subnet_azs[0]
  ebs_size          = 10
  ebs_type          = "gp3"
  instance_id       = module.inventory_db_instance.instance_id
  tags              = { Name = "inventory-db-volume" }
}

module "billing_db_instance" {
  source                    = "../modules/aws/ecs_db_instance"
  host_name                 = "billing-db"
  iam_instance_profile_name = local.ecs_instance_profile_name
  security_group_id         = local.ecs_instance_sg_id
  subnet_id                 = local.private_subnet_ids[0]
  cluster_name              = module.ecs.cluster_name
  device_name               = "sdi"
}

module "billing_db_volume" {
  source            = "../modules/aws/ebs"
  device_name       = "/dev/sdi"
  availability_zone = local.private_subnet_azs[0]
  ebs_size          = 10
  ebs_type          = "gp3"
  instance_id       = module.billing_db_instance.instance_id
  tags              = { Name = "billing_db_volume" }
}

module "cognito" {
  source             = "../modules/aws/cognito"
  aws_region         = var.aws_region
  alb_dns_name       = module.alb.alb_dns_name
  security_group_id  = local.aws_gateway_sg_id
  private_subnet_ids = [local.private_subnet_ids[0]]
  alb_listener_arn   = module.alb.alb_listener_arn
  domain_name = "cloud.hansel.lol"
  cert_arn = local.cert_arn
}

module "dashboard" {
  source           = "../modules/aws/dashboard"
  ecs_cluster_name = module.ecs.cluster_name
}

resource "aws_budgets_budget" "monthly_cost_alert" {
  name         = "monthly-budget-alert"
  budget_type  = "COST"
  limit_amount = "50"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = "80"
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["mustaphaboutoubdev@gmail.com"]
  }
}
