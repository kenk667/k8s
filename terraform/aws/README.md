## Terraform AWS for K8s

The stack used are;

- Terraform
- Concourse
- Bash

When you run *terrafrom apply* you'll be prompted for one value:

2. VPC Name 

The terraform will create three VPCs for management, tools, and services and will append the VPC type to the initial VPC name input as the following;

```
VPC_NAME-mgmt

VPC_NAME-tools

VPC_NAME-services
```

There is a default variable for the initial VPC CIDR range set to 10.0.0.0 which can be changed either by edtiing ../aws/variables.tf or by adding the -var argument during terrafrom apply and set the key pair as var.vpc_cidr = x.x.x.x where x is a number between 0 and 255.

A unique VPC CIDR range will automatically be created for each of the VPCs as a /16 subnet mask with the public and private subnets inheriting the VPC CIDR and changing the third octet defined in code as seen in the example below.

```
module "main_vpc" {
  source = "../modules/vpc-network"

  prefix                    = var.vpc_name
  vpc_cidr                  = "${var.vpc_cidr}/16"
  public_third_octet_start  = "100"
  private_third_octet_start = "20"
}
```

Three public and private subnets with a /20 subnet mask will be created for each VPC. The IP range for each of the subnets will start with the third octet defined in the code and increment it by 1 netnum (treated as an index number in terrafrom) within a /20 subnet mask. As an example, below is a 10.0.0.0/16 carved up into /20 ;

```
Network			- 10.0.0.0        - 10.0.15.255
Network			- 10.0.16.0       - 10.0.31.255
Network			- 10.0.32.0       - 10.0.47.255
Network			- 10.0.48.0       - 10.0.63.255
Network			- 10.0.64.0       - 10.0.79.255
Network			- 10.0.80.0       - 10.0.95.255
Network			- 10.0.96.0       - 10.0.111.255
Network			- 10.0.112.0      - 10.0.127.255
Network			- 10.0.128.0      - 10.0.143.255
Network			- 10.0.144.0      - 10.0.159.255
Network			- 10.0.160.0      - 10.0.175.255
Network			- 10.0.176.0      - 10.0.191.255
Network			- 10.0.192.0      - 10.0.207.255
Network			- 10.0.208.0      - 10.0.223.255
Network			- 10.0.224.0      - 10.0.239.255
Network			- 10.0.240.0      - 10.0.255.255
```

VPC peering will be automatically established between each VPC and collisions should be avoided with the subnet ranges unique between each VPC.

### Changes necessary to scale infrastructure

If there is a need to scale additional VPCs, the following changes will need to be made:

/aws/variables.tf

- Add a new variable name (e.g. <span style="color:red">vpcName_octet</span>) for the octet increment. They have been incrementing by 5 for sake of simplicity.

```
variable "vpcName_octet" {
  default = "15"
}
```

/aws/main.tf

- Copy line 31 and append to the end of that block and change to the variable established in previous step and give it a new name (e.g. <span style="color:red">someVPC_subnet_cidr</span> and interpolate <span style="color:orange">var.vpcName_octet</span> as the second variable)

```
someVPC_subnet_cidr = "${local.vpcs_subnet_octets_list[0]}.${var.vpcName_octet}.${local.vpcs_subnet_octets_list[2]}.${local.vpcs_subnet_octets_list[3]}"
```

- Copy the VPC module code and change the vpc_cidr with a new variable name (e.g. <span style="color:red">new_vpc</span>) that inerpolate the previous final local variable (e.g. <span style="color:orange">local.someVPC_subnet_cidr</span>)

```
module "new_vpc" {
  source = "../modules/vpc-network"

  prefix                    = "${var.vpc_name}-services"
  vpc_cidr                  = "${local.someVPC_subnet_cidr}/16"
}
```

- Copy one of peering modules, change the name (e.g. <span style="color:red">newVPC-services</span>) and make necessary changes to enable peering to desired VPCs. Example below will peer thew new VPC from the previous step to services_vpc. Be aware the variables that interpolate within needs to be changed where appropriate(e.g. <span style="color:orange">module.new_vpc.vpc_id</span>, <span style="color:orange">module.new_vpc.route_table_ids</span>, <span style="color:orange">module.new_vpc.cidr_block</span>). The traversal direction can be set towards the end of the block of code. By default the traversal is set to 'false' in ./modules/vpc-peering/variables.tf and must be explicitly set to '<span style="color:green">true</span>' to allow traversal.

```
module "newVPC-services" {
  source = "../modules/vpc-peering"

  vpc1_name = "newVPC"
  vpc1_id   = "${module.new_vpc.vpc_id}"
  vpc1_route_table_ids = "${module.new_vpc.route_table_ids}"
  vpc1_cidr = "${module.new_vpc.cidr_block}"

  vpc2_name = "services"
  vpc2_id   = "${module.services_vpc.vpc_id}"
  vpc2_route_table_ids = "${module.services_vpc.route_table_ids}"
  vpc2_cidr = "${module.services_vpc.cidr_block}"

  vpc1_to_vpc2 = true
  vpc2_to_vpc1 = true
}
```



