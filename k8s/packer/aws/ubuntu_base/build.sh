#!/bin/sh
export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/service-madhatter/credentials"
echo $AWS_SHARED_CREDENTIALS_FILE
export AWS_DEFAULT_PROFILE="some_profile"
ech0 $AWS_DEFAULT_PROFILE
packer build -force ubuntu.json
