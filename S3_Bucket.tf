provider "aws" {
  region = "eu-west-1"
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "sebastian-rone-terraform-bucket"
  tags = {
    Name        = "sebastian-rone-terraform-bucket"
    Environment = "Dev"
  }
}

# output "bucket_name" {
#   value = aws_s3_bucket.example_bucket.bucket
# }
#
# output "bucket_arn" {
#   value = aws_s3_bucket.example_bucket.arn
# }