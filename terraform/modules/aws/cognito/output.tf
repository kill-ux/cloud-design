output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.pool.id
}

output "cognito_user_pool_client_id" {
  description = "The Client ID for client applications"
  value       = aws_cognito_user_pool_client.client.id
}


output "api_gateway_url" {
  description = "The API Gateway endpoint URL"
  value = aws_apigatewayv2_api.gateway.api_endpoint
}