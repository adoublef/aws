resource "aws_s3_bucket" "tfstate" {
  bucket = "adoublef_aws_tfstate"
}

resource "aws_s3_bucket_acl" "tfstate" {
    bucket = aws_s3_bucket.tfstate.id
    acl = "private"
}