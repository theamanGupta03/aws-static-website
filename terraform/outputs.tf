# ─────────────────────────────────────────────
# OUTPUTS  –  printed after `terraform apply`
# ─────────────────────────────────────────────

output "website_url" {
  description = "Your website URL (open this in the browser)"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "s3_bucket_name" {
  description = "S3 bucket name — use this in the sync command"
  value       = aws_s3_bucket.website.id
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID — use this to invalidate cache"
  value       = aws_cloudfront_distribution.website.id
}

output "api_endpoint" {
  description = "Direct API Gateway endpoint (also accessible via CloudFront at /api/*)"
  value       = aws_apigatewayv2_api.website.api_endpoint
}

output "api_hello_url" {
  description = "Test this URL in your browser to verify Lambda is working"
  value       = "${aws_apigatewayv2_api.website.api_endpoint}/api/hello"
}
