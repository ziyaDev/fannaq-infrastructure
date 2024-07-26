output "vpc_id" {
  value = aws_vpc.vpc.id
  }

output "igw_id" {
  value = aws_internet_gateway.igw.id
  }
output "public_rt_id" {
  value = aws_route_table.public_rt.id
  }
output "private_rt_id" {
  value = aws_route_table.private_rt.id
  }
output "ngw_id" {
  value = aws_nat_gateway.nat_gw[0].id
  }
