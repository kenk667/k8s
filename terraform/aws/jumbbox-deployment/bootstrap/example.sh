#!/usr/bin/env bash

set -e
#change/set versions of software here
FLY_CLI_VERSION='5.2.0'
CREDHUB_CLI_VERSION='2.4.0'
TERRAFORM_VERSION='0.12.1'
K9S_VERSION= '0.7.6'
POPEYE_VERSION= '0.3.8'
STERN_VERSION= '1.10.0'

# Update and install basics
sudo apt-get update
sudo apt-get -y install jq unzip sipcalc

# Install AWS CLI
sudo apt-get -y install awscli

# Configure git, change values for your account
git config --global user.name "YOUR_NAME"                 #<=Change Here
git config --global user.email "YOUR_EMAIL@DOMAIN.COM"    #<=Change Here

# Instals fly CLI
wget https://github.com/concourse/concourse/releases/download/v${FLY_CLI_VERSION}/fly-${FLY_CLI_VERSION}-linux-amd64.tgz
tar -xvf fly-${FLY_CLI_VERSION}-linux-amd64.tgz
chmod +x fly
sudo mv fly /usr/local/bin/

#Install Credhub CLI
wget https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/${CREDHUB_CLI_VERSION}/credhub-linux-${CREDHUB_CLI_VERSION}.tgz
tar -zxvf credhub-linux-${CREDHUB_CLI_VERSION}.tgz
rm credhub-linux-${CREDHUB_CLI_VERSION}.tgz
sudo mv  credhub /usr/local/bin/credhub

# Install Terraform
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
chmod +x terraform
sudo mv terraform /usr/local/bin/

# Install K9s (K8s cluster mgmt cli)
wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_${K9S_VERSION}_Linux_x86_64.tar.gz
tar -zxvf k9s_${K9S_VERSION}_linux_amd64.zip
rm k9s_${K9S_VERSION}_linux_amd64.zip
chmod +x k9s
sudo mv k9s /usr/local/bin/

#Install Kubectx (Kubernetes Context Switcher, https://github.com/ahmetb/kubectx)

wget -O ~/.kubectx https://github.com/ahmetb/kubectx/blob/master/completion/kubectx.bash
wget https://github.com/ahmetb/kubectx/blob/master/kubectx
chomd +x ~/.kubectx
chmod +x kubectx
sudo mv kubectx /usr/local/bin
COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx
cat << FOE >> ~/.bashrc
#kubectx and kubens
export PATH=~/.kubectx:\$PATH
FOE

# Install Kubeens (Kubernetes namespace switcher, https://github.com/ahmetb/kubectx)

wget -O ~/.kubeens https://github.com/ahmetb/kubectx/blob/master/completion/kubeens.bash
wget https://github.com/ahmetb/kubectx/blob/master/kubectx
chomd +x ~/.Kubeens
chmod +x kubeens
sudo mv kubeens /usr/local/bin
COMPDIR=$(pkg-config --variable=completionsdir bash-completion)
ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx
cat << FOE >> ~/.bashrc
#kubectx and kubens
export PATH=~/.kubectx:\$PATH
FOE

# Install PS1 (K8s Context and Namespace shell prompt, https://github.com/jonmosco/kube-ps1)
wget -O ~/.ps1 https://github.com/jonmosco/kube-ps1/blob/master/kube-ps1.sh
chmod +x ~/.ps1
source ~/.ps1
PS1='[\u@\h \W $(kube_ps1)]\$ '

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