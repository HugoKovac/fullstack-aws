output "function_path" {
  value = var.functions_path
}


output "bootstrap_dirs" {
  value = local.bootstrap_dirs
}


output "lambda_function_arn" {
  value       = { for k, fn in aws_lambda_function.lambda : k => fn.arn }
  description = "ARNs of all Lambda functions"
}

output "lambda_function_names" {
  value       = { for k, fn in aws_lambda_function.lambda : k => fn.function_name }
  description = "Names of all Lambda functions"
}


output "api_gateway_id" {
  value       = aws_apigatewayv2_api.api.id
  description = "ID of the API Gateway"
}

output "api_execution_arn" {
  value       = aws_apigatewayv2_api.api.execution_arn
  description = "Execution ARN of the API Gateway"
}

output "api_endpoint" {
  value       = aws_apigatewayv2_stage.stage.invoke_url
  description = "Invoke URL of the API Gateway stage"
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_username" {
  value = var.db_username
}

output "rds_db_name" {
  value = var.db_name
}

