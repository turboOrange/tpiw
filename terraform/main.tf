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

resource "aws_api_gateway_rest_api" "api" {
  name = "tpiy-api"
}





