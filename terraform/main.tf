provider "aws" {
  region = var.aws_region
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "tpiy-user-pool"
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "tpiy-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = false
  allowed_oauth_flows_user_pool_client = true
  supported_identity_providers = ["COGNITO"]
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  callback_urls = ["http://localhost:8000/auth/callback"]
  logout_urls   = ["http://localhost:8000"]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_lambda_function" "vault_service" {
  function_name = "tpiy-vault-service"
  role          = var.lambda_exec_role
  handler       = "app.lambda_handler"
  runtime       = "python3.11"
  filename      = "../vault_service/deployment.zip"
  source_code_hash = filebase64sha256("../vault_service/deployment.zip")
  environment {
    variables = {
      REDIS_URL = var.redis_url
    }
  }
}

resource "aws_lambda_function" "otac_service" {
  function_name = "tpiy-otac-service"
  role          = var.lambda_exec_role
  handler       = "app.lambda_handler"
  runtime       = "python3.11"
  filename      = "../otac_service/deployment.zip"
  source_code_hash = filebase64sha256("../otac_service/deployment.zip")
  environment {
    variables = {
      REDIS_URL = var.redis_url
    }
  }
}

resource "aws_lambda_function" "auth_service" {
  function_name = "tpiy-auth-service"
  role          = var.lambda_exec_role
  handler       = "app.lambda_handler"
  runtime       = "python3.11"
  filename      = "../auth_service/deployment.zip"
  source_code_hash = filebase64sha256("../auth_service/deployment.zip")
  environment {
    variables = {
      COGNITO_REGION       = var.aws_region,
      COGNITO_USERPOOL_ID  = aws_cognito_user_pool.user_pool.id,
      COGNITO_CLIENT_ID    = aws_cognito_user_pool_client.user_pool_client.id
    }
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name = "tpiy-api"
}

resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_method" "auth_get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.auth.id
  http_method   = "GET"
  authorization = "NONE" # Optionally use "COGNITO_USER_POOLS" here
}

resource "aws_api_gateway_integration" "auth_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.auth_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.auth_service.invoke_arn
}

resource "aws_lambda_permission" "allow_api_gateway_auth" {
  statement_id  = "AllowExecutionFromAPIGatewayAuth"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.auth_get_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}

