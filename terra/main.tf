terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "profile" {
  description = "AWS profile name"
  type        = string
  default     = "default"
}

variable "domain_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "hprod.xyz"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "hprod.xyz"
}

variable "route53_zone_id" {
  description = "Hosted Zone ID du domaine"
  type = string
  default = "Z0765961Q2G1JKMVFG2T"
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
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

resource "aws_lambda_function" "lambda" {
  filename      = "../src/test_lambda.zip"
  function_name = "test_lambda"
  role          = aws_iam_role.go_lambda_role.arn
  handler       = "main.handler"
  runtime       = "provided.al2"
  architectures = ["arm64"]
  memory_size   = 1024
  timeout       = 300
}

# Cognito

resource "aws_cognito_user_pool" "pool" {
  name = "example_user_pool"
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "example_external_api"
  user_pool_id = aws_cognito_user_pool.pool.id

  generate_secret = false

  allowed_oauth_flows = [
    "code"
  ]

  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile"
  ]

  allowed_oauth_flows_user_pool_client = true

  callback_urls = [
    "http://localhost:3000/callback"
  ]

  logout_urls = [
    "http://localhost:3000/logout"
  ]

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  supported_identity_providers = [
    "COGNITO"
  ]
}


resource "random_id" "suffix" {
  byte_length = 4
}


resource "aws_cognito_user_pool_domain" "domain" {
  domain       = "hkovac-login-${random_id.suffix.hex}"
  user_pool_id = aws_cognito_user_pool.pool.id
}

output "cognito_domain" {
  value = "https://${aws_cognito_user_pool_domain.domain.domain}.auth.${var.region}.amazoncognito.com"
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.pool.id
}

output "vite_env_file" {
  value = "VITE_COGNITO_DOMAIN=\"https://${aws_cognito_user_pool_domain.domain.domain}.auth.${var.region}.amazoncognito.com\"\nVITE_COGNITO_CLIENT_ID=\"${aws_cognito_user_pool_client.client.id}\"\nVITE_COGNITO_LOGOUT_URI=\"logout\"\nVITE_COGNITO_AUTHORITY=\"https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.pool.id}\""
}



# API Gateway

resource "aws_apigatewayv2_api" "api" {
  name          = "serverless_lambda_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "auth" {
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.client.id]
    issuer   = "https://${aws_cognito_user_pool.pool.endpoint}"
  }
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api.id

  name        = "v1"
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

# s3

resource "aws_s3_bucket" "site" {
  bucket = "${var.bucket_name}"
}

resource "aws_s3_bucket_ownership_controls" "vite_react_bucket_ownership" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

output "bucket_name" {
  value = aws_s3_bucket.site.bucket
}

output "bucket_domain_name" {
  description = "URL of the deployed React app"
  value       = "http://${var.bucket_name}.s3-website.${var.region}.amazonaws.com"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
  profile = "${var.profile}"
}

resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}



