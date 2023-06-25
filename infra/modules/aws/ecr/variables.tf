variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image mutability"
  type        = string
  default     = "MUTABLE"
}