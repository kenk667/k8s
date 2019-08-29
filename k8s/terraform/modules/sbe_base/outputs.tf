output "eip" {
  value = aws_eip.eip.public_ip
}

output "eip_public_dns" {
  value = aws_eip.eip.public_dns
}

output "instance_name" {
  value = aws_instance.sbe_ec2.tags
}

output "instance_id" {
  value = aws_instance.sbe_ec2.id
}

output "instance_arn" {
  value = aws_instance.sbe_ec2.arn
}

output "instance_az" {
  value = aws_instance.sbe_ec2.availability_zone
}

output "instance_public_dns" {
  value = aws_instance.sbe_ec2.public_dns
}

output "instance_security_groups" {
  value = aws_instance.sbe_ec2.security_groups
}

output "instance_vpc_security_group_ids" {
  value = aws_instance.sbe_ec2.vpc_security_group_ids
}


output "instance_subnet_id" {
  value = aws_instance.sbe_ec2.subnet_id
}

output "ami_id" {
  value = var.sbe_ami
}

//output "sbe_ami_id" {
//  value = aws_ami_from_instance.sbe_ssh_2_ami.id
//}
//
//output "sbe_ami_name" {
//  value = aws_ami_from_instance.sbe_ssh_2_ami.name
//}
//output "minikube_init_rendered" {
//  value = data.template_file.init_minikube.rendered
//}

//output "cloud_init" {
//  value = data.template_file.init_minikube.rendered
//}

//output "kubeadm_token" {
//  value = module.kubeadm_token
//}