terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Primary AWS Provider
provider "aws" {
  region  = var.region
  profile = var.profile
}

# Secondary provider for us-east-1 (required for ACM with CloudFront)
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.profile
}

# Frontend Module - S3 Hosting
module "frontend" {
  source = "./modules/frontend"

  bucket_name = var.bucket_name
  region      = var.region
}

# Domains Module - Cognito, ACM, Route53
module "domains" {
  source = "./modules/domains"

  domain_name            = var.domain_name
  route53_zone_id        = var.route53_zone_id
  region                 = var.region
  bucket_website = module.frontend.bucket_website

  providers = {
    aws.us_east_1 = aws.us_east_1
  }
}

# Backend Module - Lambda & API Gateway
module "backend" {
  source = "./modules/backend"
  cognito_client_id      = module.domains.cognito_client_id
  cognito_issuer         = "https://cognito-idp.${var.region}.amazonaws.com/${module.domains.cognito_user_pool_id}"
}


