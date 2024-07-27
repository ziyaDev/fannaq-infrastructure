data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create repo for each app
module "app_repo" {
  count   = length(var.apps)
  source         = "../../infrastructure-modules/ecr"
  env            = var.env
  name           = lower(var.apps[count.index].name)
  }
#  Create IAM OpenID Connect provider role for github
resource "aws_iam_role" "role" {
  name           = "github_role_${lower(var.apps[count.index].name)}"
  count          = length(var.apps)
  description    = "Allow github actions to access ecr app repo (${var.apps[count.index].name})"
  assume_role_policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
              },
              "Action": "sts:AssumeRoleWithWebIdentity",
              "Condition": {
                "ForAllValues:StringLike": {
                  "token.actions.githubusercontent.com:sub": "repo:${var.apps[count.index].repo}:${var.env}",
                  "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                                }
              }
          }
      ]
  })
  tags = {
    "Environment" = var.env
  }
}
resource "aws_iam_policy" "ecr_access" {
  name        = "ECRAccessPolicyFor_${var.apps[count.index].name}"
  count   = length(var.apps)
  description = "Policy to allow GitHub Actions to access ECR for ${var.apps[count.index].name}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:ListImages"
        ],
        Resource = [
          "${module.app_repo[count.index].repo_arn}"
          ]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecr_access_attachment" {
  count      = length(var.apps)
  policy_arn = aws_iam_policy.ecr_access[count.index].arn
  role      = aws_iam_role.role[count.index].name
  depends_on = [aws_iam_policy.ecr_access]
}
