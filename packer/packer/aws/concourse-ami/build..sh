#!/bin/sh
#!/usr/bin/env bash

set -x
set -e
ARTIFACT_PREFIX='concourse' # <= change this to what you're building, e.g. concourse

export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/service-madhatter/credentials"
echo $AWS_SHARED_CREDENTIALS_FILE
export AWS_DEFAULT_PROFILE="some_profile"
ech0 $AWS_DEFAULT_PROFILE
packer build -force ${ARTIFACT_PREFIX}.json
sleep 10

set -e
FIRST_VAR=$(cat ../../../terraform/aws/variables.tf | grep ${ARTIFACT_PREFIX} | grep ami- | cut -d'-' -f2 | cut -d'"' -f1)
SECOND_VAR=$(cat ${ARTIFACT_PREFIX}-build-artifacts.json | grep ami- | cut -d':' -f3 | cut -d'"' -f1 | cut -d'-' -f2)
echo ${FIRST_VAR}
echo ${SECOND_VAR}

sed -i "s/ami-${FIRST_VAR}/ami-${SECOND_VAR}/g" ../../../terraform/aws/variables.tf

echo $(cat ../../../terraform/aws/variables.tf | grep ${ARTIFACT_PREFIX} | cut -d'#' -f1)
