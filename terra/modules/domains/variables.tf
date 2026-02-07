variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "cognito_pool_name" {
  description = "Name of the Cognito user pool"
  type        = string
  default     = "hprod_user_pool"
}

variable "cognito_client_name" {
  description = "Name of the Cognito user pool client"
  type        = string
  default     = "hprod_external_api"
}

variable "cognito_domain_prefix" {
  description = "Domain prefix for Cognito"
  type        = string
  default     = "hprod-login"
}

variable "callback_urls" {
  description = "OAuth callback URLs"
  type        = list(string)
  default     = ["https://hprod.xyz/"]
}

variable "logout_urls" {
  description = "OAuth logout URLs"
  type        = list(string)
  default     = ["https://hprod.xyz/"]
}

variable "bucket_website" {
  type = string
}
