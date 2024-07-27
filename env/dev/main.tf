

locals {
  aws_region = "eu-west-3"
  env        = "dev"
}

provider "aws" {
  region = local.aws_region
  }

module "network" {
  source = "../../modules/aws/infrastructure-live/network"
  region = local.aws_region
  env = local.env
  }
module "ecs" {
  source = "../../modules/aws/infrastructure-live/ecs"
  env = local.env
  apps = [{
      repo        = "ziyaDev/fannaq-api"
      description = "Backend app"
      name        = "Fannaq-api"
    }]
  }
