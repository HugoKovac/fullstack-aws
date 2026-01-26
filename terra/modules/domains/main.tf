terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
      configuration_aliases = [
        aws.us_east_1,
      ]
    }
  }
}

# Cognito User Pool
resource "aws_cognito_user_pool" "pool" {
  name = var.cognito_pool_name
}

resource "aws_cognito_user_pool_client" "client" {
  name         = var.cognito_client_name
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

  callback_urls = var.callback_urls

  logout_urls = var.logout_urls

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
  domain       = "${var.cognito_domain_prefix}-${random_id.suffix.hex}"
  user_pool_id = aws_cognito_user_pool.pool.id
}

# ACM Certificate for Custom Domain
resource "aws_acm_certificate" "cert" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"
}

# Route53 Records for Certificate Validation
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

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# CDN

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "default"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  aliases = [
    var.domain_name,
  ]

  origin {
    domain_name = var.bucket_website
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "root" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}


