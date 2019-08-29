resource "aws_instance" "nginx_ec2" {
  ami                         = var.nginx_ami
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
  provisioner "file" {
    source     = "nginx.conf"
    destination = "~/nginx.conf"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.key_path}")}"
      host = "${self.public_ip}"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sleep 80 && sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y docker.io nginx",
      "cat ~/.ssh/antipode.pub >> ~/.ssh/authorized_keys",
      "sudo mv ~/nginx.conf /etc/nginx/nginx.conf"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_path}")}"
      host = "${self.public_ip}"
    }
  }

  tags = {
    Name = "${var.vpc_name}-nginx_ec2"
  }
}

# =======================================
#               ELASTIC IP
# =======================================
resource "aws_eip" "eip" {
  instance = aws_instance.nginx_ec2.id
  vpc      = true

  tags = {
    Name = "${var.vpc_name}-nginx_ec2-eip"
  }
}


