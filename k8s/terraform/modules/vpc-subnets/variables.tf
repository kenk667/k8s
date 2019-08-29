variable "name" {
  description = "Name of the subnet, actual name will be, for example: name_eu-west-1a"
}

variable "cidrs" {
  type        = list(string)
  description = "List of cidrs for the subnet(s)"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of avalibility zones for the subnet(s)"
}

variable "vpc_id" {
  description = "VPC id to place to subnet(s) into"
}

variable "route_table_id" {
  description = "ID of the route table to associate the subnet(s) with"
}

# variable "third_octet_start" {
# }
