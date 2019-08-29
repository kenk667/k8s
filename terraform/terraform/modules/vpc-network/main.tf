data "aws_availability_zones" "available_zones" {
}

resource "aws_vpc" "vpc" {
  count                = 1
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_default_route_table" "main_rt" {
  default_route_table_id = aws_vpc.vpc[0].default_route_table_id

  tags = {
    Name = "${var.prefix}-main-route-table"
  }
}