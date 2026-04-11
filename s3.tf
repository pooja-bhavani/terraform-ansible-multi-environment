resource "random_id" "bucket_id" {
  count       = local.current.s3
  byte_length = 4
}

resource "aws_s3_bucket" "terrabucket" {
  count = local.current.s3

  bucket = "terra-bucket-${terraform.workspace}-${count.index}"

  tags = {
    Name        = "${terraform.workspace}-bucket-${count.index}"
    Environment = terraform.workspace
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = local.current.s3
  bucket = aws_s3_bucket.terrabucket[count.index].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count  = local.current.s3
  bucket = aws_s3_bucket.terrabucket[count.index].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  count  = local.current.s3
  bucket = aws_s3_bucket.terrabucket[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}