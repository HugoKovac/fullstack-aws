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

locals {
  # Find all bootstrap files
  bootstrap_files = [
    for p in fileset(var.functions_path, "**/bootstrap") :
    p
  ]

  # Extract the parent directory of each bootstrap file
  bootstrap_dirs = [
    for f in local.bootstrap_files :
    dirname(f)
  ]
}


data "archive_file" "lambda_zip" {
  for_each    = toset(local.bootstrap_dirs)
  type        = "zip"
  source_dir  = "${var.functions_path}/${each.key}"
  output_path = "${path.module}/dist/${basename(each.key)}.zip"
}


resource "aws_lambda_function" "lambda" {
  for_each = data.archive_file.lambda_zip

  function_name    = each.key
  filename         = each.value.output_path
  source_code_hash = each.value.output_base64sha256

  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  architectures = var.lambda_architectures
  role          = aws_iam_role.go_lambda_role.arn
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
  for_each = aws_lambda_function.lambda

  api_id             = aws_apigatewayv2_api.api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = each.value.invoke_arn
}

resource "aws_apigatewayv2_route" "endpoint" {
  for_each = aws_apigatewayv2_integration.integration

  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "GET /${each.key}"
  target             = "integrations/${each.value.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.auth.id
}

resource "aws_lambda_permission" "permission" {
  for_each = aws_lambda_function.lambda

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# Security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Allow Postgres access"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Subnet group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "rds-subnet-group"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier            = "my-postgres-db"
  engine                = "postgres"
  engine_version        = "14"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 20

  username = var.db_username
  password = var.db_password
  db_name  = var.db_name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  deletion_protection = false
  skip_final_snapshot = true
  publicly_accessible = true
}
