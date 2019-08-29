variable "aws_region" {
  type = string
  default = "us-gov-west-1"
}

variable "vpc_name" {
  type = string
  description = "Enter the name of the VPC that you want to deploy rancher to"
}

variable "rancher_ami_id" {default = "ami-ec387b8d"} # <= MUST keep this one line so that shell script doesn't break
