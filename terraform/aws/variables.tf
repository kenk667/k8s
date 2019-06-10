variable "aws_profile" {
  default = "some_profile"
}

variable "aws_region" { 
  default = "us-gov-west-1" 
}

variable "vpc_name" {
  description = "This will be the name of your VPC"
  type = string
}

variable "vpc_cidr" {
  description = "This will be the IP CIDR range as a /16 subnet mask for your VPC"
  default = "10.0.0.0"
  type = string
}

variable "tools_octet" {
  default = "5"
}

variable "services_octet" {
  default = "10"
}

