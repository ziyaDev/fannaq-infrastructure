

locals {
  aws_region = "us-east-1"
}

provider "aws" {
  region = local.aws_region
  }

module "network" {
  source = "../modules/aws/infrastructure-live/network"
  region = local.aws_region
  }
