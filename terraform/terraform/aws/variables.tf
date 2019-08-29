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

variable "minikube_ami_id" {default = "ami-65357604"} # <= MUST keep this one line so that shell script doesn't break

variable "sbe_ami_id" {default = "ami-65357604"} # <= MUST keep this one line so that shell script doesn't break

variable "concourse_ami_id" {default = "ami-6535760433443f52"} # <= MUST keep this one line so that shell script doesn't break

variable "charmed_k8_ami_id" {default = "ami-65357604"} # <= MUST keep this one line so that shell script doesn't break

variable "rancher_ami_id" {default = "ami-65357604"} # <= MUST keep this one line so that shell script doesn't break