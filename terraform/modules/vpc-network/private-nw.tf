# =======================================
#           PRIVATE Module
# =======================================
module "private_subnets" {
  source = "../vpc-subnets"

  name               = "${var.prefix}-private-subnet"
  vpc_id             = aws_vpc.vpc[0].id
  cidrs              = ["${cidrsubnet(var.vpc_cidr, 4, 4)}", "${cidrsubnet(var.vpc_cidr, 4, 5)}", "${cidrsubnet(var.vpc_cidr, 4, 6)}"]
  availability_zones = flatten([data.aws_availability_zones.available_zones.names])
  route_table_id     = aws_route_table.private_subnets_route_table.id
}

# =======================================
#           PRIVATE ROUTE TABLE
# =======================================
resource "aws_route_table" "private_subnets_route_table" {
  vpc_id = aws_vpc.vpc[0].id

  tags = {
    Name = "${var.prefix}-private-subnet-route-table"
  }
}

resource "aws_route" "private_subnets_route" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  route_table_id         = aws_route_table.private_subnets_route_table.id
}

resource "aws_eip" "nat_gw_eip" {
  vpc = true

  tags = {
    Name = "${var.prefix}-nat-gw-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = flatten([module.public_subnets.ids])[0]

  tags = {
    Name = "${var.prefix}-nat-gw"
  }
}

