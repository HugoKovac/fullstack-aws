output "cognito_domain" {
  value       = "https://${aws_cognito_user_pool_domain.domain.domain}.auth.${var.region}.amazoncognito.com"
  description = "Cognito domain URL"
}

output "cognito_client_id" {
  value       = aws_cognito_user_pool_client.client.id
  description = "Cognito client ID"
}

output "cognito_user_pool_id" {
  value       = aws_cognito_user_pool.pool.id
  description = "Cognito user pool ID"
}

output "vite_env_file" {
  value = "VITE_COGNITO_DOMAIN=\"https://${aws_cognito_user_pool_domain.domain.domain}.auth.${var.region}.amazoncognito.com\"\nVITE_COGNITO_CLIENT_ID=\"${aws_cognito_user_pool_client.client.id}\"\nVITE_COGNITO_LOGOUT_URI=\"logout\"\nVITE_COGNITO_AUTHORITY=\"https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.pool.id}\""
  description = "Vite environment variables for Cognito"
}

output "acm_certificate_arn" {
  value       = aws_acm_certificate.cert.arn
  description = "ARN of the ACM certificate"
}
