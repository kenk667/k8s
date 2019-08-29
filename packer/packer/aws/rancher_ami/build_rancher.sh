#!/bin/sh
#!/usr/bin/env bash

set -x
set -e
ARTIFACT_PREFIX='rancher' # <= change this to what you're building, e.g. concourse

export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"
echo $AWS_SHARED_CREDENTIALS_FILE
export AWS_DEFAULT_PROFILE="some_profile"
echo $AWS_DEFAULT_PROFILE
NEW_AMI=$(cat ../sbe_base/sbe-16.04-build-artifacts.json | grep ami- | awk '{gsub(",",""); gsub("\\\"",""); gsub(":",""); gsub("us-gov-west-1",""); print$2}')
OLD_AMI=$(cat rancher.json | grep ami- | awk '{gsub(":",""); gsub("\\\"",""); gsub(",",""); print$2}')
cat rancher.json | grep ami- | sed -i "s/${OLD_AMI}/${NEW_AMI}/g" rancher.json
PACKER_LOG=debug packer build -force ${ARTIFACT_PREFIX}.json
sleep 10

set -e
FIRST_VAR=$(cat ../../../terraform/aws/${ARTIFACT_PREFIX}/variables.tf | grep ${ARTIFACT_PREFIX} | grep ami- | cut -d'-' -f2 | cut -d'"' -f1)
SECOND_VAR=$(cat ${ARTIFACT_PREFIX}-build-artifacts.json | grep ami- | cut -d':' -f3 | cut -d'"' -f1 | cut -d'-' -f2)
echo ${FIRST_VAR}
echo ${SECOND_VAR}

#sed -i "s/ami-${FIRST_VAR}/ami-${SECOND_VAR}/g" ../../../terraform/aws/variables.tf
sed -i "s/ami-${FIRST_VAR}/ami-${SECOND_VAR}/g" ../../../terraform/aws/rancher/rancher_node/variables.tf
sed -i "s/ami-${FIRST_VAR}/ami-${SECOND_VAR}/g" ../../../terraform/aws/rancher/etcd/variables.tf
sed -i "s/ami-${FIRST_VAR}/ami-${SECOND_VAR}/g" ../../../terraform/aws/rancher/control_plane/variables.tf

echo $(cat ${ARTIFACT_PREFIX}-build-artifacts.json | grep ami-)
