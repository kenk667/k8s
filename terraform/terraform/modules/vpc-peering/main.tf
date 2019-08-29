resource "aws_vpc_peering_connection" "peering_connection" {
  vpc_id      = var.vpc1_id
  peer_vpc_id = var.vpc2_id
  auto_accept = true
  tags = {
    Name = "${var.vpc1_name}-${var.vpc2_name}"
  }
}

resource "aws_vpc_peering_connection_options" "peering_connection_options" {
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_route" "vpc1_to_vpc2" {
  count                     = var.vpc1_to_vpc2 ? length(var.vpc1_route_table_ids) : 0
  destination_cidr_block    = var.vpc2_cidr
  route_table_id            = element(var.vpc1_route_table_ids, count.index)
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}

resource "aws_route" "vpc2_to_vpc1" {
  count                     = var.vpc2_to_vpc1 ? length(var.vpc2_route_table_ids) : 0
  destination_cidr_block    = var.vpc1_cidr
  route_table_id            = element(var.vpc2_route_table_ids, count.index)
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_connection.id
}

