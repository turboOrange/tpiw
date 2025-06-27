output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.user_pool_domain.domain
}

# terraform/backend.tf (optional S3 state config)
terraform {
  backend "s3" {
    bucket = "tpiy-terraform-state-bucket"
    key    = "tpiy/terraform.tfstate"
    region = "us-east-1"
  }
}
