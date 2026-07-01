# 1. Repositorio para Members
resource "aws_ecr_repository" "members" {
  name                 = "${var.project_name}/members"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration { scan_on_push = true }
}

# 2. Repositorio para Billing
resource "aws_ecr_repository" "billing" {
  name                 = "${var.project_name}/billing"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration { scan_on_push = true }
}

# 3. Repositorio para Access Control
resource "aws_ecr_repository" "access_control" {
  name                 = "${var.project_name}/access-control"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration { scan_on_push = true }
}

locals {
  ecr_lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Mantener las ultimas 10 imagenes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}

resource "aws_ecr_lifecycle_policy" "members" {
  repository = aws_ecr_repository.members.name
  policy     = local.ecr_lifecycle_policy
}

resource "aws_ecr_lifecycle_policy" "billing" {
  repository = aws_ecr_repository.billing.name
  policy     = local.ecr_lifecycle_policy
}

resource "aws_ecr_lifecycle_policy" "access_control" {
  repository = aws_ecr_repository.access_control.name
  policy     = local.ecr_lifecycle_policy
}