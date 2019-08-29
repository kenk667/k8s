variable "aws_region" {
  type = string
  default = "us-gov-west-1"
}

# ============= General =============
variable "prefix" {
  type    = string
  default = "management"
}

variable "vpc_name" {
  type = string
  description = "Enter the name of the VPC that you want to deploy jumpboxes to"
}

