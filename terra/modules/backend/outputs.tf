output "lambda_function_arn" {
  value       = aws_lambda_function.lambda.arn
  description = "ARN of the Lambda function"
}

output "lambda_function_name" {
  value       = aws_lambda_function.lambda.function_name
  description = "Name of the Lambda function"
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
