output "vpc_id" {
  value = aws_vpc.vpc[0].id
}

output "private_subnet_ids" {
  value = module.private_subnets.ids
}

output "public_subnet_ids" {
  value = module.public_subnets.ids
}

output "cidr_block" {
  value = aws_vpc.vpc[0].cidr_block
}

output "route_table_ids" {
  value = [aws_route_table.public_subnets_route_table.id, aws_route_table.private_subnets_route_table.id]
}

output "public_vpc_subnets" {
  value = ["${cidrsubnet(var.vpc_cidr, 4, 1)}", "${cidrsubnet(var.vpc_cidr, 4, 2)}", "${cidrsubnet(var.vpc_cidr, 4, 3)}"]
}
output "private_vpc_subnets" {
  value = ["${cidrsubnet(var.vpc_cidr, 4, 4)}", "${cidrsubnet(var.vpc_cidr, 4, 5)}", "${cidrsubnet(var.vpc_cidr, 4, 6)}"]
}
