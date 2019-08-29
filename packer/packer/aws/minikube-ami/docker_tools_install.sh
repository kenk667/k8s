#!/usr/bin/env bash

set -e

K9S_VERSION='0.7.6'
POPEYE_VERSION='0.3.8'
STERN_VERSION='1.10.0'

# Update and install basics
sudo apt-get update
sudo apt-get install -y ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker.io

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