module "ecr" {
  source          = "terraform-aws-modules/ecr/aws"
  repository_name = local.ecr.name

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  create_lifecycle_policy           = true
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

  repository_force_delete         = true
  repository_image_tag_mutability = "MUTABLE" #hot-fix

  tags = {
    Terraform = "true"
  }
}
