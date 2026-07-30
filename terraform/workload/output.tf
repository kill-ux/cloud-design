output "alb_dns_name" {
  description = "The public DNS URL of the Load Balancer"
  value       = module.alb.alb_dns_name
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = module.cognito.cognito_user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "The Client ID for client applications"
  value       = module.cognito.cognito_user_pool_client_id
}

output "api_gateway_url" {
  description = "The API Gateway endpoint URL"
  value       = module.cognito.api_gateway_url
}


output "target_domain_name" {
  value = module.cognito.target_domain_name
}

