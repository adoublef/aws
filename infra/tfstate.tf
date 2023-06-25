module "tfstate_s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.tfstate.bucket
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

module "tfstate_dynamodb" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name         = local.tfstate.dynamodb
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  tags = {
    Terraform = "true"
  }
}
