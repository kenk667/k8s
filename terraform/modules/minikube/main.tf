resource "aws_instance" "minikube" {
  ami                         = var.minikube_ami
  instance_type               = "m3.medium"
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  security_groups             = [var.security_group_id]
  associate_public_ip_address = "true"

  root_block_device {
    volume_size = "128" #in GB
  }

  lifecycle {
    ignore_changes = [security_groups]
  }

  tags = {
    Name = "${var.vpc_name}-minikube"
  }
}

# =======================================
#               ELASTIC IP
# =======================================
resource "aws_eip" "eip" {
  instance = aws_instance.minikube.id
  vpc      = true

  tags = {
    Name = "${var.vpc_name}-minikube-eip"
  }
}

