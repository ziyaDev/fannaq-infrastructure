

resource "aws_ecr_repository" "ecr" {
  name                 = "${var.name}_repository"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  tags = {
    "Enviremnent" :var.env
    }
}
