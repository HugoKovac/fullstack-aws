terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = "eu-west-3"
  profile = "default"
}


resource "aws_iam_role" "go_lambda_role" {
  name = "go_lambda_role"
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

# Lambda

resource "aws_lambda_function" "test_lambda" {
  filename      = "../src/test_lambda.zip"
  function_name = "test_lambda"
  role          = aws_iam_role.go_lambda_role.arn
  handler       = "main.handler"
  runtime       = "provided.al2"
  architectures = ["arm64"]
  memory_size   = 1024
  timeout       = 300
}

# API Gateway

resource "aws_apigatewayv2_api" "test_lambda_api" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "test_lambda_api_stage" {
  api_id = aws_apigatewayv2_api.test_lambda_api.id

  name        = "v1"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "test_gw_intergration" {
  api_id = aws_apigatewayv2_api.test_lambda_api.id

  integration_uri    = aws_lambda_function.test_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "gw_lambda_endpoint" {
  api_id = aws_apigatewayv2_api.test_lambda_api.id


  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.test_gw_intergration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.test_lambda_api.execution_arn}/*/*"
}

