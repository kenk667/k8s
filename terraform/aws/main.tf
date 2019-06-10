provider "aws" {
  region  = "us-gov-west-1"
  profile = "some_profile"
}
#It's important to have the correct terraform versiosn, all versions at https://releases.hashicorp.com/terraform/
terraform {
  required_version = ">= 0.12"  
  backend "s3" {
    bucket  = "antipode"
    key     = "terraform/aws/newDeploy/terrafrom.tfstate"
    region  = "us-gov-west-1"
    profile = "some_profile"
  }
}
data "aws_availability_zones" "available_zones" {}
# =======================================
#           MGMT VPC
# =======================================
module "management_vpc" {
  source = "../modules/vpc-network"

  prefix                    = "${var.vpc_name}-mgmt"
  vpc_cidr                  = "${var.vpc_cidr}/16"
}
# =======================================
#           Tools & Services VPC
# =======================================
locals {
  vpcs_subnet_octets_list = split(".", var.vpc_cidr)
  tools_subnet_cidr = "${local.vpcs_subnet_octets_list[0]}.${var.tools_octet}.${local.vpcs_subnet_octets_list[2]}.${local.vpcs_subnet_octets_list[3]}"
  svc_subnet_cidr = "${local.vpcs_subnet_octets_list[0]}.${var.services_octet}.${local.vpcs_subnet_octets_list[2]}.${local.vpcs_subnet_octets_list[3]}"
}
module "tools_vpc" {
  source = "../modules/vpc-network"

  prefix                    = "${var.vpc_name}-tools"
  vpc_cidr                  = "${local.tools_subnet_cidr}/16"
}
module "services_vpc" {
  source = "../modules/vpc-network"

  prefix                    = "${var.vpc_name}-services"
  vpc_cidr                  = "${local.svc_subnet_cidr}/16"
}
# =======================================
#           VPC Peering
# =======================================
module "management-tools" {
  source = "../modules/vpc-peering"

  vpc1_name = "management"
  vpc1_id   = "${module.management_vpc.vpc_id}"
  vpc1_route_table_ids = "${module.management_vpc.route_table_ids}"
  vpc1_cidr = "${module.management_vpc.cidr_block}"

  vpc2_name = "tools"
  vpc2_id   = "${module.tools_vpc.vpc_id}"
  vpc2_route_table_ids = "${module.tools_vpc.route_table_ids}"
  vpc2_cidr = "${module.tools_vpc.cidr_block}"

  vpc1_to_vpc2 = true
  vpc2_to_vpc1 = true
}
module "management-services" {
  source = "../modules/vpc-peering"

  vpc1_name = "management"
  vpc1_id   = "${module.management_vpc.vpc_id}"
  vpc1_route_table_ids = "${module.management_vpc.route_table_ids}"
  vpc1_cidr = "${module.management_vpc.cidr_block}"

  vpc2_name = "services"
  vpc2_id   = "${module.services_vpc.vpc_id}"
  vpc2_route_table_ids = "${module.services_vpc.route_table_ids}"
  vpc2_cidr = "${module.services_vpc.cidr_block}"

  vpc1_to_vpc2 = true
  vpc2_to_vpc1 = true
}
module "tools-services" {
  source = "../modules/vpc-peering"

  vpc1_name = "tools"
  vpc1_id   = "${module.tools_vpc.vpc_id}"
  vpc1_route_table_ids = "${module.tools_vpc.route_table_ids}"
  vpc1_cidr = "${module.tools_vpc.cidr_block}"

  vpc2_name = "services"
  vpc2_id   = "${module.services_vpc.vpc_id}"
  vpc2_route_table_ids = "${module.services_vpc.route_table_ids}"
  vpc2_cidr = "${module.services_vpc.cidr_block}"

  vpc1_to_vpc2 = true
  vpc2_to_vpc1 = true
}