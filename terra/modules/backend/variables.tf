variable "lambda_role_name" {
  description = "Name of the Lambda IAM role"
  type        = string
  default     = "go_lambda_role"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function ZIP file"
  type        = string
  default     = "../src/test_lambda.zip"
}

variable "functions_path" {
  type    = string
  default = "../src/ports/inbound"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "test_lambda"
}

variable "lambda_handler" {
  description = "Lambda handler"
  type        = string
  default     = "main.handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "provided.al2"
}

variable "lambda_architectures" {
  description = "Lambda architectures"
  type        = list(string)
  default     = ["arm64"]
}

variable "lambda_memory_size" {
  description = "Lambda memory size"
  type        = number
  default     = 1024
}

variable "lambda_timeout" {
  description = "Lambda timeout"
  type        = number
  default     = 300
}

variable "api_gateway_name" {
  description = "API Gateway name"
  type        = string
  default     = "serverless_lambda_gw"
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}

variable "authorizer_name" {
  description = "API Gateway authorizer name"
  type        = string
  default     = "cognito-authorizer"
}

variable "cognito_client_id" {
  description = "Cognito client ID for JWT audience"
  type        = string
}

variable "cognito_issuer" {
  description = "Cognito issuer URL"
  type        = string
}

variable "db_username" {
  description = "Database admin username"
  type        = string
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "hprod"
}

variable "private_subnets" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access Postgres"
  default     = ["10.0.0.0/16"]
}

