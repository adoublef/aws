module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                   = local.eks.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    workers = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      # this will override the group default
      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }

    tags = {
      ExtraTag = "adoublef-hello-world"
    }
  }

  # aws-auth configmap
  #   manage_aws_auth_configmap = true

  #   aws_auth_node_iam_role_arns_non_windows = [
  #     module.eks_managed_node_group.iam_role_arn,
  #     module.self_managed_node_group.iam_role_arn,
  #   ]

  #   aws_auth_roles = [
  #     {
  #       rolearn  = module.eks_managed_node_group.iam_role_arn
  #       username = "system:node:{{EC2PrivateDNSName}}"
  #       groups = [
  #         "system:bootstrappers",
  #         "system:nodes",
  #       ]
  #     },
  #     {
  #       rolearn  = module.self_managed_node_group.iam_role_arn
  #       username = "system:node:{{EC2PrivateDNSName}}"
  #       groups = [
  #         "system:bootstrappers",
  #         "system:nodes",
  #       ]
  #     },
  #     {
  #       rolearn  = module.fargate_profile.fargate_profile_pod_execution_role_arn
  #       username = "system:node:{{SessionName}}"
  #       groups = [
  #         "system:bootstrappers",
  #         "system:nodes",
  #         "system:node-proxier",
  #       ]
  #     }
  #   ]

  #   aws_auth_users = [
  #     {
  #       userarn  = "arn:aws:iam::66666666666:user/user1"
  #       username = "user1"
  #       groups   = ["system:masters"]
  #     },
  #     {
  #       userarn  = "arn:aws:iam::66666666666:user/user2"
  #       username = "user2"
  #       groups   = ["system:masters"]
  #     },
  #   ]

  #   aws_auth_accounts = [
  #     "777777777777",
  #     "888888888888",
  #   ]
}
