data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create repo for the app
module "app_repo" {
  source         = "../../infrastructure-modules/ecr"
  env            = var.env
  name           = lower(var.app.name)
  }
#  Create IAM OpenID Connect provider role for github
resource "aws_iam_role" "role" {
  name           = "github_role_${lower(var.app.name)}"
  description    = "Allow github actions to access ecr app repo (${var.app.name})"
  assume_role_policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringLike": {
                        "token.actions.githubusercontent.com:sub": "repo:${var.app.repo}:*"
                    },
                    "ForAllValues:StringEquals": {
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                    }
                }
            },

        ]
    }

    )
  tags = {
    "Environment" = var.env
  }
}
resource "aws_iam_policy" "ecs_access" {
  name        = "ECRAccessPolicyFor_${var.app.name}"
  description = "Policy to allow GitHub Actions to access ECR for ${var.app.name}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowPull",
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:ListImages",
        "ecr:GetLifecyclePolicy",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
        ],
        Resource = [
          "${module.app_repo.repo_arn}"
          ]
      },
      {
        Sid: "GetAuthorizationToken",
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = [
          "*"
          ]
      },
      {
          Sid= "DescribeTaskDefinition",
          Effect = "Allow",
          Action= [
              "ecs:DescribeTaskDefinition"
          ],
          Resource= "*"
      },
      {
          Sid= "RegisterTaskDefinition",
          Effect= "Allow",
          Action= [
              "ecs:RegisterTaskDefinition"
          ],
          Resource= "*"
      },
      {
          Sid= "PassRolesInTaskDefinition",
          Effect= "Allow",
          Action= [
              "iam:PassRole"
          ],
          Resource= "*"
          // Add specific ARNs if needed: ["arn:aws:iam::<aws_account_id>:role/<task_definition_task_role_name>", "arn:aws:iam::<aws_account_id>:role/<task_definition_task_execution_role_name>"]
      },
      {
          Sid= "DeployService",
          Effect= "Allow",
          Action= [
              "ecs:UpdateService",
              "ecs:DescribeServices"
          ],
          Resource= "*"
          // Add specific ARNs if needed: ["arn:aws:ecs:<region>:<aws_account_id>:service/<cluster_name>/<service_name>"]
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_access_attachment" {
  policy_arn = aws_iam_policy.ecs_access.arn
  role      = aws_iam_role.role.name
  depends_on = [aws_iam_policy.ecs_access]
}
