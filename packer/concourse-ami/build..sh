#!/bin/sh
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/service-madhatter/credentials"
echo $AWS_SHARED_CREDENTIALS_FILE
packer build -force concourse.json
