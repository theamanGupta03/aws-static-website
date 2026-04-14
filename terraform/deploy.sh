#!/bin/bash
# ─────────────────────────────────────────────────────────────
# deploy.sh  –  Upload static files to S3 + invalidate cache
# Run this after `terraform apply` and any time you update files
# ─────────────────────────────────────────────────────────────

set -e

# Read outputs from Terraform
BUCKET=$(terraform output -raw s3_bucket_name)
DISTRIBUTION_ID=$(terraform output -raw cloudfront_distribution_id)
WEBSITE_URL=$(terraform output -raw website_url)

echo ""
echo "📦 Uploading website files to S3..."
aws s3 sync ../my-website s3://$BUCKET \
  --delete \
  --cache-control "max-age=86400" \
  --exclude "*.html" # HTML files get no-cache so updates show immediately

# Upload HTML files separately with no-cache header
aws s3 sync ../my-website s3://$BUCKET \
  --exclude "*" \
  --include "*.html" \
  --cache-control "no-cache, no-store, must-revalidate"

echo ""
echo "🔄 Invalidating CloudFront cache..."
aws cloudfront create-invalidation \
  --distribution-id $DISTRIBUTION_ID \
  --paths "/*" \
  --query 'Invalidation.Id' \
  --output text

echo ""
echo "✅ Done! Your site is live at:"
echo "   $WEBSITE_URL"
echo ""
