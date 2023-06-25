terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "adoublef-aws-tfstate"
    key            = "infra.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "adoublef-aws-tfstate-lock"
    encrypt        = true    
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "tfstate" {
  source = "./modules/aws/tfstate"
}