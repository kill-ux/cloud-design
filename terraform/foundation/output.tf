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