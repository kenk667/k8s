#!/bin/bash
set -x


export KUBEADM_TOKEN=${kubeadm_token}
export DNS_NAME=${dns_name}
#export IP_ADDRESS=${ip_address}
export CLUSTER_NAME=${cluster_name}
#export ADDONS="${addons}"
export KUBERNETES_VERSION="1.14.3"

# This IP is link local to within the EC2 instance and this method retrieves the local hostname expected by kubectl and kubeadm
FULL_HOSTNAME="$(curl -s http://169.254.169.254/latest/meta-data/hostname)"

cat >> kubeadm.yaml <<EOF
---

apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: $KUBEADM_TOKEN
  ttl: 0s
  usages:
  - signing
  - authentication
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  kubeletExtraArgs:
    cloud-provider: aws
    read-only-port: "10255"
  name: $FULL_HOSTNAME
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---

apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
apiServer:
  certSANs:
  - $DNS_NAME
  #- $IP_ADDRESS
  extraArgs:
    cloud-provider: aws
  timeoutForControlPlane: 5m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager:
  extraArgs:
    cloud-provider: aws
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kubernetesVersion: v$KUBERNETES_VERSION
networking:
  dnsDomain: cluster.local
  podSubnet: ""
  serviceSubnet: 10.96.0.0/12

EOF

kubeadm reset --force
kubeadm init --config kubeadm.yaml #--ignore-preflight-errors=SystemVerification

# Use the local kubectl config for further kubectl operations
export KUBECONFIG=/etc/kubernetes/admin.conf


# Allow all apps to run on master
kubectl taint nodes --all node-role.kubernetes.io/master-

# Allow load balancers to route to master
kubectl label nodes --all node-role.kubernetes.io/master-

# Allow the user to administer the cluster
kubectl create clusterrolebinding admin-cluster-binding --clusterrole=cluster-admin --user=admin

# Prepare the kubectl config file for download to client (IP address)
export KUBECONFIG_OUTPUT=kubeconfig_ip
#kubeadm alpha kubeconfig user \
#  --client-name admin \
#  --apiserver-advertise-address $IP_ADDRESS \
#  > $KUBECONFIG_OUTPUT
chown centos:centos $KUBECONFIG_OUTPUT
chmod 0600 $KUBECONFIG_OUTPUT