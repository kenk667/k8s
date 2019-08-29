provider "aws" {
  region     = var.aws_region
  profile    = "some_profile"
}
#Change belwo values to yours
terraform {
  backend "s3" {
    bucket = "antipode"
    key    = "terraform/aws/rancher_node/terraform.tfstate"
    region = "us-gov-west-1"
    profile    = "some_profile"
  }
}

#This data source gets a list of VPCs based on the user-inputted VPC name 
data "aws_vpcs" "vpc_list" {
  filter {
    name   = "tag-value"
    values = ["${var.vpc_name}-services-vpc"]
  }
}

#This block selects the first VPC from the list of vpcs generated in "vpc_list"
//Just fixed below to v12 syntax, the list had to be flatten first and then pick which out of that list outside of that backet
data "aws_vpc" "vpc" {
  id = flatten([data.aws_vpcs.vpc_list.ids])[0]
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
  tags = {
    Name = "*public*"
  }
}

# =======================================
#            SECURITY GROUP
# =======================================
resource "aws_security_group" "rancher_node_sg" {
  name        = "${var.vpc_name}-rancher_node-sg2"
  description = " Security group for services-vpc rancher_node-ami"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-rancher_node-sg2"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  description       = "ssh ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  description       = "http ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  description       = "https ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}
# =======================================
#               Rancher Ports
# =======================================

resource "aws_security_group_rule" "docker_daemon" {
  type              = "ingress"
  description       = "rancher_node docker daemon ingress"
  from_port         = 2376
  to_port           = 2376
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

resource "aws_security_group_rule" "flannel_udp" {
  type              = "ingress"
  description       = "flannel UDP ingress"
  from_port         = 8472
  to_port           = 8472
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

resource "aws_security_group_rule" "flannel_tcp" {
  type              = "ingress"
  description       = "flannel TCP ingress"
  from_port         = 9099
  to_port           = 9099
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}
# =======================================
#               K8 Ports
# =======================================

resource "aws_security_group_rule" "kubelet" {
  type              = "ingress"
  description       = "kubelet ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

resource "aws_security_group_rule" "k8s_api_secure" {
  type              = "ingress"
  description       = "K8 API ingress TLS"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

resource "aws_security_group_rule" "k8s_api_insecure" {
  type              = "ingress"
  description       = "K8 API ingress Non-TLS"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

resource "aws_security_group_rule" "etcd" {
  type              = "ingress"
  description       = "etcd ingress"
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

resource "aws_security_group_rule" "k8_scheduler_controller-manager" {
  type              = "ingress"
  description       = "k8_scheduler_controller-manager ingress"
  from_port         = 10251
  to_port           = 10252
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

# =======================================
#               Egress
# =======================================

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  description       = "all out egress"
  from_port         = -1
  to_port           = -1
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rancher_node_sg.id
}

# =======================================
#               SBE-Instance
# =======================================

module "rancher_node_base" {
  source = "../../../modules/rke"

  key_name              = "kkato"
  key_path              = "/home/meow/.ssh/kessel/kkato.pem"
  subnet_id             = element(tolist(data.aws_subnet_ids.public.ids), 0)
  vpc_name              = "${var.vpc_name}-services-vpc"
  security_group_id     = aws_security_group.rancher_node_sg.id
  rke_ami               = var.rancher_node_ami_id
  service_name          = "rke"
}

