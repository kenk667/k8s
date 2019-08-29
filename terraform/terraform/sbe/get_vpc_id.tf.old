provider "aws" {
  region  = "us-gov-west-1"
  profile = "some_profile"
}

#It's important to have the correct terraform versiosn, all versions at https://releases.hashicorp.com/terraform/
terraform {
  required_version = "0.11.14"
  required_providers {
    aws = "2.11.0"
  }  
  backend "s3" {
    bucket = "antipode"
    key = "{{some/patj/to/state}}"
    region = "us-gov-west-1"
    profile = "some_profile"
  }
}

variable "aws_profile" {
    default = "some_profile"
    }
variable "aws_region" {
    default = "us-gov-west-1"
    }
variable "vpc_name" {}

#This data source fetches the current available zones based on the region set in the provider
data "aws_availability_zones" "available_zones" {}

#This data source gets a list of VPCs based on the user-inputted VPC name 
data "aws_vpcs" "vpc_list" {
  filter = {
    name = "tag-value",
    values = ["${var.vpc_name}"]
  }
}
