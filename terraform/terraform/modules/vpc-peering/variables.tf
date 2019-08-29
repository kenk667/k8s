variable "vpc1_name" {
}

variable "vpc1_id" {
}

variable "vpc1_route_table_ids" {
  type = list(string)
}

variable "vpc1_cidr" {
}

variable "vpc2_name" {
}

variable "vpc2_id" {
}

variable "vpc2_route_table_ids" {
  type = list(string)
}

variable "vpc2_cidr" {
}

variable "vpc1_to_vpc2" {
  default = false
}

variable "vpc2_to_vpc1" {
  default = false
}

