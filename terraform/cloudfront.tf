# ─────────────────────────────────────────────
# ORIGIN ACCESS CONTROL (OAC)
# Replaces the old OAI — the secure way to let
# CloudFront read from a private S3 bucket.
# ─────────────────────────────────────────────

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.project_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ─────────────────────────────────────────────
# CLOUDFRONT DISTRIBUTION
# ─────────────────────────────────────────────

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "${var.project_name} static website"
  price_class         = "PriceClass_100" # US, Canada, Europe (cheapest)

  # ── Origin 1: S3 bucket (static files) ──────
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  # ── Origin 2: API Gateway (dynamic /api/* calls) ──
  origin {
    domain_name = replace(
      aws_apigatewayv2_api.website.api_endpoint,
      "https://", ""
    )
    origin_id = "APIGatewayOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # ── Default cache behaviour → S3 (HTML/CSS/JS) ──
  default_cache_behavior {
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Cache static assets for 1 day
    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # ── /api/* cache behaviour → API Gateway ──
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "APIGatewayOrigin"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Content-Type"]
      cookies {
        forward = "none"
      }
    }

    # Don't cache API responses
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # ── Custom error pages (SPA support) ──
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  # ── Geo restriction (none for now) ──
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ── SSL certificate ──
  viewer_certificate {
    cloudfront_default_certificate = true   # uses *.cloudfront.net domain + free SSL
    # To use your own domain, replace the line above with:
    # acm_certificate_arn      = aws_acm_certificate.website.arn
    # ssl_support_method       = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
