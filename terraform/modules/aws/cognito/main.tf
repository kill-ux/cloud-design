# Cognito User Pool
resource "aws_cognito_user_pool" "pool" {
  name = "cloud-design-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

# App Client
resource "aws_cognito_user_pool_client" "client" {
  name            = "cloud-design-user-pool-client"
  user_pool_id    = aws_cognito_user_pool.pool.id
  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# HTTP API Gateway
resource "aws_apigatewayv2_api" "gateway" {
  name          = "cloud-design-http-api"
  protocol_type = "HTTP"
}

# Auto-deploying Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.gateway.id
  name        = "$default"
  auto_deploy = true
}

# JWT Authorizer
resource "aws_apigatewayv2_authorizer" "cognito_auth" {
  api_id           = aws_apigatewayv2_api.gateway.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.pool.id}"
  }
}

# ALB Backend Integration
resource "aws_apigatewayv2_integration" "integration" {
  api_id             = aws_apigatewayv2_api.gateway.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"

  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.alb_link.id
  integration_uri = var.alb_listener_arn
}

# Protected Route
resource "aws_apigatewayv2_route" "protected_route" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "ANY /{proxy+}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_auth.id

  target = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_vpc_link" "alb_link" {
  name               = "api-gateway-vpc-link"
  security_group_ids = [var.security_group_id]
  subnet_ids         = var.private_subnet_ids
}


resource "aws_apigatewayv2_domain_name" "custom_domain" {
  domain_name = var.domain_name
  domain_name_configuration {
    certificate_arn = var.cert_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "mapping" {
  api_id      = aws_apigatewayv2_api.gateway.id
  domain_name = aws_apigatewayv2_domain_name.custom_domain.id
  stage       = aws_apigatewayv2_stage.default.id
}

data "aws_route53_zone" "this" {
  name         = "hansel.lol"
  private_zone = false
}

resource "aws_route53_record" "api_custom_domain" {
  zone_id = data.aws_route53_zone.this.zone_id
  name = var.domain_name
  type = "CNAME"
  ttl = 300
  records = [aws_apigatewayv2_domain_name.custom_domain.domain_name_configuration[0].target_domain_name]
}