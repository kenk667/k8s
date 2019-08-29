#create snowballEdge profile from ./snowballEdge list-access-keys then ./snowballEdge get-secret-access-key --access-key-id to get SBE API creds
provider "aws" {
  region  = "us-gov-west-1"
  profile = "snowballEdge"
  endpoints {
    ec2      = "http://10.1.100.210:8008"
    s3       = "http://10.1.100.210:8080"
  }
}

#It's important to have the correct terraform versiosn, all versions at https://releases.hashicorp.com/terraform/
//terraform {
//  required_version = ">= 0.12"
//  backend "s3" {
//    bucket  = "antipode"
//    key     = "terraform/sbe/terrafrom.tfstate"
//    region  = "us-gov-west-1"
//    profile = "snowballEdge"
//  }
//}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    endpoint = "http://10.1.100.210:8080"
    region = "us-gov-west-1" # Basically this gets ignored.
    profile = "snowballEdge"
    bucket = "antipode"
    key = "terrafrom.tfstate"
    force_path_style = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
  }
}

data "aws_availability_zones" "available_zones" {}
