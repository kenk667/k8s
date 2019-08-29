# Jumpbox Terraform Module

## Usage Example

Change module name value from "your_jumpbox" by replacing 'yourName' and append to end of main.tf within this folder. The scripts for the EC2 configuration is located in a subfolder within this directory /bootstrap. Copy the example.sh and make appropariate changes and rename to your name.

```
module "yourName_jumpbox" {
  source = "../../modules/jump_box"

  key_name              = "youName"
  key_path              = "/home/USER/.ssh/sshkey.pem"
  subnet_id             = element(tolist(data.aws_subnet_ids.public.ids), 0)
  vpc_name                = var.vpc_name
  operator_name         = "yourName"
  bootstrap_script_path = "bootstrap/yourName.sh"
  security_group_id     = aws_security_group.jumpbox_sg.id
}

```
