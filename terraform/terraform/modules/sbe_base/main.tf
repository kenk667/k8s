resource "aws_instance" "sbe_ec2" {
  ami                         = var.sbe_ami
  instance_type               = "t3.2xlarge"
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  security_groups             = [var.security_group_id]
  associate_public_ip_address = "true"
  cpu_core_count              = "4"
  cpu_threads_per_core        = "2"

  root_block_device {
    volume_size = "128" #in GB
  }

  lifecycle {
    ignore_changes = [security_groups]
  }

  #It's important to use content vs source. source will try to interpret literal the rendered output which will create an invalid file or dest. error
  provisioner "file" {
    source     = "/home/meow/ssh_pub/antipode.pub" #change this as needed
    destination = "~/.ssh/antipode.pub"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.key_path}")}"
      host = "${self.public_ip}"
    }
  }
//###NEED TO FIX BELOW, trying to decouple the sudo commands for kube stuff and everything else
  provisioner "remote-exec" {
    inline = [
      "cat ~/.ssh/antipode.pub >> ~/.ssh/authorized_keys",
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_path}")}"
      host = "${self.public_ip}"
    }
  }

  tags = {
    Name = "${var.vpc_name}-sbe_ec2"
  }
}

# =======================================
#               ELASTIC IP
# =======================================
resource "aws_eip" "eip" {
  instance = aws_instance.sbe_ec2.id
  vpc      = true

  tags = {
    Name = "${var.vpc_name}-sbe_ec2-eip"
  }
}

#Commented this out to create AMIs from script so that AMIs persist even is the instance is gone, also commented out AMI info on outputs file
# =======================================
#               AMI
//# =======================================
//resource "aws_ami_from_instance" "sbe_ssh_2_ami" {
//  name               = "sbe_base_xenial_ami"
//  source_instance_id = aws_instance.sbe_ec2.id
//  tags = {
//    Name = "sbe_base_xenial_ami"
//  }
//}

