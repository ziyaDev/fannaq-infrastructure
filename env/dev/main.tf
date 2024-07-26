

locals {
  aws_region = "eu-west-3"
}

provider "aws" {
  region = local.aws_region
  }

module "network" {
  source = "../../modules/aws/infrastructure-live/network"
  region = local.aws_region
  env = "Development"
  }
