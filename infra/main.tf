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

provider "aws" {
  region = local.region
}

# zones accessible by the AWS account within the region
# configure the in the provider block
data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}