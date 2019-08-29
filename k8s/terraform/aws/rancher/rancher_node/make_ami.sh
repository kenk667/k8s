#!/bin/bash
#!/usr/bin/env bash

set -x
set -e

SBE_BASE="sbe_base_xenial_ami"
SBE_AMI_ID="sbe_base_ami_id.txt"
IMAGE_DESCRIPTION="Base xenial AMI for SBE"

if terraform output | grep instance_id; then
        INSTANCE_ID=$(terraform output | grep instance_id | awk '{{gsub(",",""); gsub("\\\"",""); print $3}}')

else
        echo "Need to terraform apply!"
        exit 0
fi

if aws ec2 describe-images --profile some_profile --filter "Name=name,Values=$SBE_BASE" | grep $SBE_BASE; then


        while true; do
    read -p "An AMI already exists, do you want to deregister the existing one and create new? Y/N? " yn
    case $yn in
        [Yy]* )  IMAGE_ID=$(aws ec2 describe-images --profile some_profile --filter "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}')
                 aws ec2 deregister-image --profile some_profile --image-id $IMAGE_ID
                 aws ec2 create-image --profile some_profile  --instance-id $INSTANCE_ID --name "$SBE_BASE" --description "$IMAGE_DESCRIPTION"
                 echo "Image created, AMI ID is saved to $SBE_AMI_ID $(aws ec2 describe-images --profile some_profile --filters "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}' > $SBE_AMI_ID)"
                 break;;
        [Nn]* ) echo "Existing AMI ID is $(
aws ec2 describe-images --profile some_profile --filters "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}') and available on $SBE_AMI_ID"; exit;;
        * ) echo "Please answer yes(Y/y) or no(N/n).";;
    esac
done

else
        aws ec2 create-image --profile some_profile  --instance-id $INSTANCE_ID --name "$SBE_BASE" --description "$IMAGE_DESCRIPTION"
        echo "Image created, AMI ID is saved to $SBE_AMI_ID $(aws ec2 describe-images --profile some_profile --filters "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}' > $SBE_AMI_ID)"
fi