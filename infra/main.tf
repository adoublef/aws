terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    region         = "eu-west-2"
    key            = "adoublef.aws.tfstate"
    bucket         = "adoublef-aws-tfstate"
    dynamodb_table = "adoublef-aws-tfstate-lock"
    encrypt        = true
  }
}

locals {
  region           = "eu-west-2"
  repository       = "adoublef-aws-repository"
  tfstate_bucket   = "adoublef-aws-tfstate"
  tfstate_dynamodb = "adoublef-aws-tfstate-lock"
}

provider "aws" {
  region = local.region
}

module "tfstate_s3" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.tfstate_bucket
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

module "tfstate_dynamodb" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name         = local.tfstate_dynamodb
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

module "ecr" {
  source          = "terraform-aws-modules/ecr/aws"
  repository_name = local.repository

  # repository_read_write_access_arns
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true

  tags = {
    Terraform = "true"
  }
}
