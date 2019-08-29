variable "key_name" {
}

variable "subnet_id" {
}

variable "key_path" {
}

variable "vpc_name" {
}

variable "security_group_id" {
}

variable "sbe_ami" {
}

#fix this maybe with coalese in the future to pick aws gc, sbe, etc for the second portion of the hosted domain context in kubeadm
variable "hosted_zone" {
  default = "awsgc"
}

//variable "addons" {
//  description = "list of YAML files with Kubernetes addons which should be installed"
//  type        = "list"
//}