#!/bin/sh
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/service-madhatter/credentials"
echo $AWS_SHARED_CREDENTIALS_FILE
PACKER_LOG=1 packer build -force minikube.json
