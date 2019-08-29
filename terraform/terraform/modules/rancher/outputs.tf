output "eip" {
  value = aws_eip.eip.public_ip
}

output "eip_public_dns" {
  value = aws_eip.eip.public_dns
}

output "instance_name" {
  value = aws_instance.rancher_ec2.tags
}

output "instance_id" {
  value = aws_instance.rancher_ec2.id
}

output "instance_arn" {
  value = aws_instance.rancher_ec2.arn
}

output "instance_az" {
  value = aws_instance.rancher_ec2.availability_zone
}

output "instance_public_dns" {
  value = aws_instance.rancher_ec2.public_dns
}

output "instance_security_groups" {
  value = aws_instance.rancher_ec2.security_groups
}

output "instance_vpc_security_group_ids" {
  value = aws_instance.rancher_ec2.vpc_security_group_ids
}


output "instance_subnet_id" {
  value = aws_instance.rancher_ec2.subnet_id
}

output "ami_id" {
  value = var.rancher_ami
}
