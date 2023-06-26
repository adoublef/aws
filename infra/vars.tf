locals {
  region = "eu-west-2"

  tfstate = {
    bucket   = "adoublef-aws-tfstate"
    dynamodb = "adoublef-aws-tfstate-lock"
  }

  ecr = {
    name = "adoublef-aws-repository"
  }

  vpc = {
    name = "adoublef-aws-vpc"
    cidr = "10.0.0.0/20"
    azs  = slice(data.aws_availability_zones.available.names, 0, 2)
  }

  eks = {
    name = "adoublef-aws-eks"
  }
}
