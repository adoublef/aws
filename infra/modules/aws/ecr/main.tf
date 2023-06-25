resource "aws_ecr_repository" "registry" {
  name                 = var.ecr_name
  image_tag_mutability = var.image_tag_mutability
}
