resource "aws_s3_bucket" "secure_bucket" {
  bucket = "beamreach-${var.env}-secure"
}

resource "aws_s3_bucket_public_access_block" "secure_block" {
  bucket                  = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "beamreach-${var.env}-insecure"
}

resource "aws_s3_bucket_ownership_controls" "insecure_controls" {
  bucket = aws_s3_bucket.insecure_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "insecure_block" {
  bucket                  = aws_s3_bucket.insecure_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket" "logging_bucket" {
  bucket = "beamreach-${var.env}-logging"
}

resource "aws_s3_bucket_public_access_block" "logging_block" {
  bucket                  = aws_s3_bucket.logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "logging_config" {
  bucket = aws_s3_bucket.secure_bucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "logs/"
}