# VPC Peering Connection Terraform Module
Module for creating a VPC peering connection between two VPCs.

## Usage Example
```
module "vpc-peer-connection" {
  source = "../modules/vpc-peering"

  vpc1_name = "tools"
  vpc1_id   = "some-id"
  vpc1_route_table_ids = ["some-id", "some-other-id"]
  vpc1_cidr = "some-cidr"

  vpc2_name = "tools"
  vpc2_id   = "some-id"
  vpc2_route_table_ids = ["some-id", "some-other-id", "some-third-id"]
  vpc2_cidr = "some-cidr"

  vpc1_to_vpc2 = true
  vpc2_to_vpc1 = true
}
```