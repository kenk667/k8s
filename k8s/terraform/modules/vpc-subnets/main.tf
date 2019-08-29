resource "aws_subnet" "subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = element(var.cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.cidrs)

  tags = {
    Name = "${var.name}_${element(var.availability_zones, count.index)}"
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = length(var.cidrs)
  subnet_id      = element(aws_subnet.subnet.*.id, count.index)
  route_table_id = var.route_table_id
}

