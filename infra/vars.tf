# zones accessible by the AWS account within the region
# configure the in the provider block
data "aws_availability_zones" "available" {}

locals {
  region     = "eu-west-2"
  repository = "adoublef-aws-repository"

  tfstate = {
    bucket   = "adoublef-aws-tfstate"
    dynamodb = "adoublef-aws-tfstate-lock"
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