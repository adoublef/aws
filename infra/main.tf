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
