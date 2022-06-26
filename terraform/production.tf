terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.0.0"
    }
  }
}

provider "aws" {
  region                   = local.region
  shared_credentials_files = var.shared_cred_file
}

resource "aws_kms_key" "this" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  tags                    = var.resource_tags
}

resource "aws_vpc" "this" {
  cidr_block = "10.17.0.0/24"
  tags       = var.resource_tags
}

# S3 Storage

resource "aws_s3_bucket" "this" {
  bucket = local.shared_obj_name
  tags   = var.resource_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_object" "folder_uploads" {
  bucket       = aws_s3_bucket.this.id
  key          = "uploads/"
  content_type = "application/x-directory; charset=UTF-8"
  tags         = var.resource_tags
}
