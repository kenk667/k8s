#this data block needs to be updated for every ami release to taget for a given OS and version since it filters to a given OS and version, but picks the latest tag in terms of AMI creation date
data "aws_ami" "ubuntu_bionic" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["513442679011"] # Canonical
}

resource "aws_instance" "jumpbox" {
  ami                         = data.aws_ami.ubuntu_bionic.id
  instance_type               = "t2.small"
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  security_groups             = ["${var.security_group_id}"]
  associate_public_ip_address = "true"

  root_block_device {
    volume_size = "64"
  }

  lifecycle {
    ignore_changes = ["security_groups"]
  }

  provisioner "remote-exec" {
    script = "${var.bootstrap_script_path}"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("${var.key_path}")}"
      host = "${self.public_ip}"
    }
  }

  tags = {
    Name = "${var.vpc_name}-${var.operator_name}-jumpbox"
  }

}

# =======================================
#               ELASTIC IP
# =======================================
resource "aws_eip" "eip" {
  instance = "${aws_instance.jumpbox.id}"
  vpc      = true

  tags = {
    Name = "${var.vpc_name}-${var.operator_name}-jumpbox-eip"
  }

}
