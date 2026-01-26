output "bucket_name" {
  value       = aws_s3_bucket.site.bucket
  description = "Name of the S3 bucket"
}

output "bucket_domain_name" {
  value       = "http://${var.bucket_name}.s3-website.${var.region}.amazonaws.com"
  description = "URL of the deployed React app"
}

output "bucket_arn" {
  value       = aws_s3_bucket.site.arn
  description = "ARN of the S3 bucket"
}

output "bucket_website" {
  value = aws_s3_bucket.site.bucket_regional_domain_name
}
