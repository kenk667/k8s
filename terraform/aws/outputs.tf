# output "aws_vpc_id" {
#   value = data.aws_vpc.vpc0.id
# }

# output "aws_vpc_cidr_block" {
#   value = data.aws_vpc.vpc0.cidr_block
# }

# output "ec2-test-ip" {value = aws_instance.web.public_ip }

//try to create 3 routes - one from public (1a, 1b, 1c) - 

output "aws_AZs" {
  value = data.aws_availability_zones.available_zones.names
  description = "These are your AWS AZs"
}

# =======================================
#            VPC Names
# =======================================
output "mgmt_vpc_name" {
  value = "${var.vpc_name}-mgmt-vpc"
}

output "services_vpc_name" {
  value = "${var.vpc_name}-services-vpc"
}

output "tools_vpc_name" {
  value = "${var.vpc_name}-tools-vpc"
}

# =======================================
#            VPC CIDR & Subnets
# =======================================

output "mgmt_vpc_ip_range_and_ids" {
  value = module.management_vpc
}

output "services_vpc_ip_range_and_ids" {
  value = module.services_vpc
}

output "tools_vpc_ip_range_and_ids" {
  value = module.tools_vpc
}
