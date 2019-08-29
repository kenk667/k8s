resource "aws_instance" "rancher_ec2" {
  ami                         = var.rancher_ami
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
  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher",
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_path}")}"
      host = "${self.public_ip}"
    }
  }

  tags = {
    Name = "${var.vpc_name}-rancher_ec2"
  }
}

# =======================================
#               ELASTIC IP
# =======================================
resource "aws_eip" "eip" {
  instance = aws_instance.rancher_ec2.id
  vpc      = true

  tags = {
    Name = "${var.vpc_name}-rancher_ec2-eip"
  }
}


