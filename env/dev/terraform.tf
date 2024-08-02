
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
    }
  }
  required_version = ">= 1.2.0"
  cloud {
    organization = "Fannaq"
    workspaces {
      name = "dev"
    }
  }
}
provider "aws" {
  region = var.aws_region
}
