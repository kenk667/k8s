output "eip" {
  value = aws_eip.eip.public_ip
}

output "eip_public_dns" {
  value = aws_eip.eip.public_dns
}

output "instance_name" {
  value = aws_instance.minikube.tags
}

output "instance_id" {
  value = aws_instance.minikube.id
}

output "instance_arn" {
  value = aws_instance.minikube.arn
}

output "instance_az" {
  value = aws_instance.minikube.availability_zone
}

output "instance_public_dns" {
  value = aws_instance.minikube.public_dns
}

output "instance_security_groups" {
  value = aws_instance.minikube.security_groups
}

output "instance_vpc_security_group_ids" {
  value = aws_instance.minikube.vpc_security_group_ids
}


output "instance_subnet_id" {
  value = aws_instance.minikube.subnet_id
}

output "ami_id" {
  value = var.minikube_ami
}

//output "minikube_init_rendered" {
//  value = data.template_file.init_minikube.rendered
//}

//output "cloud_init" {
//  value = data.template_file.init_minikube.rendered
//}

//output "kubeadm_token" {
//  value = module.kubeadm_token
//}