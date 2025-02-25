provider "aws" {
  region     = var.aws_region
  profile    = "some_profile"
}

terraform {
  backend "s3" {
    bucket = "antipode"
    key    = "terraform/aws/jump-box/terraform.tfstate"
    region = "us-gov-west-1"
    profile    = "some_profile"
  }
}

#This data source gets a list of VPCs based on the user-inputted VPC name 
data "aws_vpcs" "vpc_list" {
  filter {
    name   = "tag-value"
    values = [var.vpc_name]
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
resource "aws_security_group" "jumpbox_sg" {
  name        = "${var.vpc_name}-jumpbox-sg2"
  description = " Security group for management jumpboxes"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-jumpbox-sg2"
  }
}

resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  description       = "ssh from outside"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jumpbox_sg.id
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  description       = "all out"
  from_port         = -1
  to_port           = -1
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jumpbox_sg.id
}

# =======================================
#               JUMPBOXES
# =======================================

module "ken_jumpbox" {
  source = "../../modules/jump_box"

 key_name              = "id_rsa" #Change This
  key_path              = "/home/user/.ssh/" #Change This
  subnet_id             = element(tolist(data.aws_subnet_ids.public.ids), 0)
  vpc_name                = var.vpc_name
  operator_name         = "USER_NAME" #Change this
  bootstrap_script_path = "bootstrap/example.sh"
  security_group_id     = aws_security_group.jumpbox_sg.id
}

