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


resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"



  tags = merge(
     {
       "Name" = format("%s", var.name)
     },
     {
       "Environment" =   var.env
     },
     var.tags,
   )
}
