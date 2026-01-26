# IAM Role for Lambda
resource "aws_iam_role" "go_lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "lambda" {
  filename      = var.lambda_zip_path
  function_name = var.lambda_function_name
  role          = aws_iam_role.go_lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  architectures = var.lambda_architectures
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout
}

# API Gateway
resource "aws_apigatewayv2_api" "api" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "auth" {
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = var.authorizer_name

  jwt_configuration {
    audience = [var.cognito_client_id]
    issuer   = var.cognito_issuer
  }
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api.id

  name        = var.api_stage_name
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id = aws_apigatewayv2_api.api.id

  integration_uri    = aws_lambda_function.lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "endpoint" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "GET /"
  target             = "integrations/${aws_apigatewayv2_integration.integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.auth.id
}

resource "aws_lambda_permission" "permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
