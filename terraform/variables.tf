variable "aws_region" {
  description = "Primary AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A short name used to prefix all resources (e.g. mywebsite)"
  type        = string
  default     = "mywebsite"
}

variable "domain_name" {
  description = "Your custom domain name (leave empty to use the CloudFront default domain)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment tag"
  type        = string
  default     = "demo"
}
