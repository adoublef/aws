module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.vpc.name
  cidr = local.vpc.cidr

  azs             = local.vpc.azs
  private_subnets = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 4, k)]
  public_subnets  = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.cidr, 8, k + 52)]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Terraform = "true"
  }
}
