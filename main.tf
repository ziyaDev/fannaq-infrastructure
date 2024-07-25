
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
  cloud {
    organization = "Fannaq"
    workspaces {
      name = "fannaq-workspace-dev"
    }
  }
}


provider "aws" {
  region = var.region
  }

module "main" {
  source = "./modules/aws/infrastructure-modules/vpc"

  }
