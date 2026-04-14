terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: store state remotely in S3 (recommended for real projects)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "static-website/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}

# Second provider in us-east-1 — required for ACM SSL certificates used by CloudFront
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
