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
