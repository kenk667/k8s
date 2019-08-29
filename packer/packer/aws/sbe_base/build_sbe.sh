#!/bin/sh

set -x
set -e

ARTIFACT_PREFIX='sbe'

export SSH_PUB_FILE="$HOME/ssh_pub/antipode.pub"
echo $SSH_PUB_FILE
export SSH_DEST="/home/ubuntu/.ssh"
echo $SSH_DEST
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"
echo $AWS_SHARED_CREDENTIALS_FILE
export AWS_DEFAULT_PROFILE="some_profile"
echo $AWS_DEFAULT_PROFILE
PACKER_LOG=debug packer build -force sbe_base.json
sleep 10

set -e
FIRST_VAR=$(cat ../../../terraform/aws/variables.tf | grep ${ARTIFACT_PREFIX} | grep ami- | cut -d'-' -f2 | cut -d'"' -f1)
SECOND_VAR=$(cat ${ARTIFACT_PREFIX}-16.04-build-artifacts.json | grep ami- | cut -d':' -f3 | cut -d'"' -f1 | cut -d'-' -f2)
echo ${FIRST_VAR}
echo ${SECOND_VAR}

sed -i "s/ami-${FIRST_VAR}/ami-${SECOND_VAR}/g" ../../../terraform/aws/variables.tf
sed -i "s/ami-${FIRST_VAR}/ami-${SECOND_VAR}/g" ../../../terraform/aws/sbe_ssh_deploy/variables.tf
sed -i "s/ami-${FIRST_VAR}/ami-${SECOND_VAR}/g" ../../../terraform/aws/rancher/nginx/variables.tf

echo $(cat ../../../terraform/aws/variables.tf | grep ${ARTIFACT_PREFIX} | cut -d'#' -f1)

