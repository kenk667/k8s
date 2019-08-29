#!/usr/bin/env bash

set -e
set -x

K9S_VERSION='0.7.6'
POPEYE_VERSION='0.3.8'
STERN_VERSION='1.10.0'
RKE_VERSION='0.2.6'
ETCD_VER='v3.3.13'
GO_VER='1.12.7'

sleep 80

# Update and install basics, really key to use tee -a for redirection and append, cat <<EOF > doesn't work in this case since it doesn't preserve sudo at redirection
sudo apt-get update
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee -a /etc/apt/sources.list
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl docker.io git
sudo apt-mark hold kubelet kubeadm kubectl
sudo apt-get upgrade -y

# Install K9s (K8s cluster mgmt cli)
wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_${K9S_VERSION}_Linux_x86_64.tar.gz
tar -zxvf k9s_${K9S_VERSION}_Linux_x86_64.tar.gz
rm k9s_${K9S_VERSION}_Linux_x86_64.tar.gz
chmod +x k9s
sudo mv k9s /usr/local/bin/

# Install PS1 (K8s Context and Namespace shell prompt, https://github.com/jonmosco/kube-ps1)
git clone https://github.com/jonmosco/kube-ps1.git
mv kube-ps1/kube-ps1.sh ~/.ps1.sh
chmod +x ~/.ps1.sh
source ~/.ps1.sh
PS1='[\u@\h \W $(kube_ps1)]\$ '
rm -rf kube-ps1

#Install Popeye, a K8s cluster sanitizer
wget https://github.com/derailed/popeye/releases/download/v${POPEYE_VERSION}/popeye_${POPEYE_VERSION}_Linux_x86_64.tar.gz
tar -zxvf popeye_${POPEYE_VERSION}_Linux_x86_64.tar.gz
rm popeye_${POPEYE_VERSION}_Linux_x86_64.tar.gz
chmod +x popeye
sudo mv popeye /usr/local/bin

#Install Stern, K8s multi pod log aggregator
wget https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64
chmod +x stern_linux_amd64
sudo mv stern_linux_amd64 /usr/local/bin/stern

#Install RKE
wget https://github.com/rancher/rke/releases/download/v${RKE_VERSION}/rke_linux-amd64
chmod +x rke_linux-amd64
sudo mv rke_linux-amd64 /usr/local/bin/rke

#Install Helm-latest, this script is written and maintained by Helm and the wget pulls their script down
wget https://raw.githubusercontent.com/helm/helm/master/scripts/get -O get_helm.sh
chmod +x get_helm.sh
./get_helm.sh

#etcd install
curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf etcd-${ETCD_VER}-linux-amd64.tar.gz && rm -f etcd-${ETCD_VER}-linux-amd64.tar.gz
sudo mv etcd-v3.3.13-linux-amd64/etcd etcd-v3.3.13-linux-amd64/etcdctl /usr/local/bin/
#ETCDCTL_API=3 /usr/local/bin//etcdctl version

#golang install, needs env setup script. setup script should be called via source to preserve env vars at build time in terraform
wget https://dl.google.com/go/go${GO_VER}.linux-amd64.tar.gz
tar xvf go${GO_VER}.linux-amd64.tar.gz
sudo mv go /usr/local/
