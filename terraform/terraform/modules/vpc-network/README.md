# VPC Network Terraform Module

Module for creating a VPC with three private subnets and three public subnets.

## Usage Example

```
module "new_vpc" {
  source = "../modules/vpc-network"

  prefix                    = "${var.vpc_name}-mgmt"
  vpc_cidr                  = "${var.vpc_cidr}/16"
}
```

