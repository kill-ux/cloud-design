output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "private_subnet_azs" {
  value = module.vpc.private_subnet_azs
}

output "service_discovery_namespace_arn" {
  value = module.vpc.service_discovery_namespace_arn
}

output "ecs_execution_role_arn" {
  value = module.iam.ecs_execution_role_arn
}

output "ecs_instance_profile_name" {
  value = module.iam.ecs_instance_profile_name
}

output "secrets_arn" {
  value = module.secrets.cloud_design_credentials_arn
}

output "ecr_registry" {
  value = module.ecr.ecr_registry
}

output "aws_gateway_sg_id" {
  value = module.aws_gateway_sg.id
}

output "alb_sg_id" {
  value = module.alb_sg.id
}

output "ecs_instance_sg_id" {
  value = module.ecs_instance_sg.id
}

output "gateway_sg_id" {
  value = module.gateway_sg.id
}

output "rabbitmq_sg_id" {
  value = module.rabbitmq_sg.id
}

output "inventory_sg_id" {
  value = module.inventory_sg.id
}
output "inventory_db_sg_id" {
  value = module.inventory_db_sg.id
}

output "billing_sg_id" {
  value = module.billing_sg.id
}

output "billing_db_sg_id" {
  value = module.billing_db_sg.id
}

output "cert_validation_record" {
  value = module.acm.cert_validation_record
}

output "cert_arn" {
  value = module.acm.cert_arn
}

output "vpc_endpoints_sg_id" {
  value = module.vpc_endpoints_sg.id
}