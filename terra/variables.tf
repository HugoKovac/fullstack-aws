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
  type        = string
  default     = "Z0765961Q2G1JKMVFG2T"
}

variable "db_username" {
  description = "Database admin username"
  type        = string
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "private_subnets" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}



