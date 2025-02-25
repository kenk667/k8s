
module "kubeadm_token" {
  source = "../kubeadm_token/"
}

data "template_file" "init_minikube" {
  template = "${file("${path.module}/scripts/minikube_init.sh")}"

  vars = {
    kubeadm_token = "${module.kubeadm_token.token}"
    dns_name      = "${var.vpc_name}.${var.hosted_zone}"
    cluster_name  = "${var.vpc_name}-k8s"
    #addons        = "${join(" ", var.addons)}
  }
}

#check on EC2 instance /var/log/cloud-init-output.txt to see current cloud-init phase
data "template_cloudinit_config" "minikube_cloud_init" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "minikube_init.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.init_minikube.rendered
  }
}

resource "aws_instance" "minikube" {
  ami                         = var.minikube_ami
  instance_type               = "m5.2xlarge"
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  security_groups             = [var.security_group_id]
  associate_public_ip_address = "true"
  cpu_core_count              = "4"
  cpu_threads_per_core        = "2"
//  user_data = data.template_cloudinit_config.minikube_cloud_init.rendered

  root_block_device {
    volume_size = "128" #in GB
  }

  lifecycle {
    ignore_changes = [security_groups]
  }

  #It's important to use content vs source. source will try to interpret literal the rendered output which will create an invalid file or dest. error
  provisioner "file" {
    content     = data.template_file.init_minikube.rendered
    destination = "~/minikube_init.sh"

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
//      "cat <<EOF > minikube_init.sh",
//      "${data.template_file.init_minikube.rendered}",
//      "EOF",
      "chmod +x minikube_init.sh",
//      "sudo minikube start --vm-driver=none",
//      "sudo minikube status",
//      "./minikube_init.sh",
//      "sudo kubeadm reset --force",
//      "sudo kubeadm init --config kubeadm.yaml",
//      "export KUBECONFIG=/etc/kubernetes/admin.conf",
//      "sudo kubectl taint nodes --all node-role.kubernetes.io/master-",
//      "sudo kubectl label nodes --all node-role.kubernetes.io/master-",
//      "sudo kubectl label nodes --all node-role.kubernetes.io/master-",
//      "sudo kubectl create clusterrolebinding admin-cluster-binding --clusterrole=cluster-admin --user=admin",
//      "export KUBECONFIG_OUTPUT=~/.kubeconfig_ip",
////      "kubeadm alpha kubeconfig user \,
////      --client-name admin \,
////      --apiserver-advertise-address $IP_ADDRESS \,
////      > kubeconfig_ip",
//      "chown ubuntu:ubuntu $KUBECONFIG_OUTPUT",
//      "chmod 0600 $KUBECONFIG_OUTPUT",
//      "cp $KUBECONFIG_OUTPUT ~/kubeconfig",
////      "sed -i "s/server: https:\/\/$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):6443/server: https:\/\/${var.vpc_name}:6443/g" ~/kubeconfig",
//      "chown ubuntu:ubuntu ~/kubeconfig",
//      "chmod 0600 ~/kubeconfig"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_path}")}"
      host = "${self.public_ip}"
    }
  }

  tags = {
    Name = "${var.vpc_name}-minikube"
  }
  #format stes the numers to 00 format, and cound.index increments
//  tags {
//
//    Name = "${var.vpc_name}-minikube${format("%02d", count.index+9)}"
//
//  }

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

