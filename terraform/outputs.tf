variable "aws_region" {
  default = "us-east-1"
}

variable "cognito_domain_prefix" {
  default = "tpiy-auth"
}

variable "lambda_exec_role" {
  description = "IAM Role ARN for executing Lambda"
  type        = string
}

variable "redis_url" {
  description = "Redis connection string"
  type        = string
}

# terraform/outputs.tf
output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.user_pool_domain.domain
}

output "auth_service_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}/auth"
}
