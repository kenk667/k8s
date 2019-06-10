# Subnet Terraform Module
Module for creating one or more subnets within a VPC.

## Usage Example
```
module "private_subnet" {
  source = "../vpc-subnets"

  name               = "${var.prefix}-private-subnet"
  vpc_id             = aws_vpc.vpc[0].id
  cidrs              = ["${cidrsubnet(var.vpc_cidr, 4, 4)}", "${cidrsubnet(var.vpc_cidr, 4, 5)}", "${cidrsubnet(var.vpc_cidr, 4, 6)}"]
  availability_zones = flatten([data.aws_availability_zones.available_zones.names])
  route_table_id     = aws_route_table.private_subnets_route_table.id
}
```