# =======================================
#           PUBLIC Module
# =======================================

module "public_subnets" {
  source = "../vpc-subnets"

  name               = "${var.prefix}-public-subnet"
  vpc_id             = aws_vpc.vpc[0].id
  cidrs              = ["${cidrsubnet(var.vpc_cidr, 4, 1)}", "${cidrsubnet(var.vpc_cidr, 4, 2)}", "${cidrsubnet(var.vpc_cidr, 4, 3)}"]
  availability_zones = flatten([data.aws_availability_zones.available_zones.names])
  route_table_id     = aws_route_table.public_subnets_route_table.id
}

# =======================================
#           PUBLIC ROUTE TABLE
# =======================================
resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.vpc[0].id

  tags = {
    Name = "${var.prefix}-public-subnet-route-table"
  }
}

resource "aws_route" "public_subnets_route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
  route_table_id         = aws_route_table.public_subnets_route_table.id
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc[0].id
  
  tags = {
    Name = "${var.prefix}-igw"
  }
}