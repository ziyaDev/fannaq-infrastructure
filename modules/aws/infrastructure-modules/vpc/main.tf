data "aws_availability_zones" "available" {}
data "aws_region" "current" {}



###########
### VPC ###
###########
resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
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


#######################
##### VPC subnets #####
#######################
resource "aws_subnet" "vpc" {
  count = length(var.subnets)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = var.subnets[count.index].map_public_ip_on_launch
  tags = {
    Name = "${var.vpc_name}_subnet_${count.index + 1}_${element(data.aws_availability_zones.available.names, count.index)}"
  }
}
######################
#### Route tables ####
######################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
    "Environment" = var.env
  }
  depends_on = [aws_vpc.vpc]
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[0].id
  }

  tags = {
    Name = "private_route_table"
    "Environment" = var.env
  }
    depends_on = [aws_vpc.vpc]
}
locals {
  public_subnet_ids = [
    for s in aws_subnet.vpc : s.id
    if s.map_public_ip_on_launch
  ]
  private_subnet_ids = [
    for s in aws_subnet.vpc : s.id
    if !s.map_public_ip_on_launch
  ]
}
resource "aws_route_table_association" "public_assoc" {
  count = length(local.public_subnet_ids)
  subnet_id      = local.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "private_assoc" {
  count = length(local.private_subnet_ids)
  subnet_id      = local.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private_rt.id
}
#######################
##### INT Gateway #####
#######################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "main"
    "Environment" = var.env
  }
}
locals {
  # Get the index of the first public subnet
  public_subnet_index = [for i, s in aws_subnet.vpc : i if s.map_public_ip_on_launch][0]
}
#######################
##### NAT Gateway #####
#######################
resource "aws_eip" "nat_eip" {
  vpc = true
}
resource "aws_nat_gateway" "nat_gw" {
  count = var.create_net_gw ? 1 : 0
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.vpc[local.public_subnet_index].id
  tags = {
    Name = "gw NAT"
    "Environment" = var.env
    }
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


###########################
##### VPC S3 ENDPOINT #####
###########################
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  tags = {
    Environment = "test"
  }
}
