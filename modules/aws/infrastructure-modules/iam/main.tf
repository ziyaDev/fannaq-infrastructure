resource "aws_iam_role" "role" {
  name = var.role_name
  description = var.description
  assume_role_policy = jsonencode(var.assume_role_policy)
  tags = {
    "Envirement" = var.env
  }
}
