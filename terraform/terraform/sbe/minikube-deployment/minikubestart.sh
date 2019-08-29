#!/bin/bash
set -x
#sudo minikube delete
sudo minikube start --vm-driver=none

# if [[ $(sudo minikube start --vm-driver=none) = "machine does not exist" ]]; then
#   $(sudo minikube delete && sudo minikubestart --vm-driver=none)
# else
# $(sleep 10)
# fi
