


resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = merge(
     {
       "Name" = "${format("%s", var.vpc_name)}-vpc"
     },
     {
       "Environment" =   var.env
     },
     var.tags,
   )
}
