# ─────────────────────────────────────────────
# S3 BUCKET  –  stores all static website files
# ─────────────────────────────────────────────

resource "aws_s3_bucket" "website" {
  bucket        = "${var.project_name}-static-website-${random_id.suffix.hex}"
  force_destroy = true   # allows terraform destroy to delete non-empty bucket

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Generate a random 4-char suffix so the bucket name is globally unique
resource "random_id" "suffix" {
  byte_length = 4
}

# Block ALL public access — only CloudFront (via OAC) can read objects
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning (optional but good practice)
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket policy — allows CloudFront OAC to call s3:GetObject
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  # Wait until public access block is applied first
  depends_on = [aws_s3_bucket_public_access_block.website]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}


