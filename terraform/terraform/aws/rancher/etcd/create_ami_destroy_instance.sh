#!/bin/bash
#!/usr/bin/env bash

set -x
set -e

SBE_BASE="sbe_base_xenial_ami"
SBE_AMI_ID="sbe_base_ami_id.txt"
IMAGE_DESCRIPTION="Base xenial AMI for SBE"

if terraform output | grep instance_id; then
        while true; do
    read -p "Terrafrom apply has been completed, would you like to run again + destroy? Y/N? " yn
    case $yn in
        [Yy]* )  terraform apply -auto-approve

                 if aws ec2 describe-images --profile some_profile --filter "Name=name,Values=$SBE_BASE" | grep $SBE_BASE; then
                 INSTANCE_ID=$(terraform output | grep instance_id | awk '{{gsub(",",""); gsub("\\\"",""); print $3}}')
                 IMAGE_ID=$(aws ec2 describe-images --profile some_profile --filter "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}')
                 aws ec2 deregister-image --profile some_profile --image-id $IMAGE_ID
                 aws ec2 create-image --profile some_profile  --instance-id $INSTANCE_ID --name "$SBE_BASE" --description "$IMAGE_DESCRIPTION"
                 echo "Image created, AMI ID is saved to $SBE_AMI_ID $(aws ec2 describe-images --profile some_profile --filters "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}' > $SBE_AMI_ID)"
                 else
                     INSTANCE_ID=$(terraform output | grep instance_id | awk '{{gsub(",",""); gsub("\\\"",""); print $3}}')
                     aws ec2 create-image --profile some_profile  --instance-id $INSTANCE_ID --name "$SBE_BASE" --description "$IMAGE_DESCRIPTION"
fi
                 terraform destroy -auto-approve
                 echo "Image created, AMI ID is saved to $SBE_AMI_ID $(aws ec2 describe-images --profile some_profile --filters "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}' > $SBE_AMI_ID)"
                 break;;
        [Nn]* ) echo "Existing AMI ID is $(
aws ec2 describe-images --profile some_profile --filters "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}') and available on $SBE_AMI_ID"; exit;;
        * ) echo "Please answer yes(Y/y) or no(N/n).";;
    esac
done

else
        terraform apply -auto-approve
        if aws ec2 describe-images --profile some_profile --filter "Name=name,Values=$SBE_BASE" | grep $SBE_BASE; then
                 INSTANCE_ID=$(terraform output | grep instance_id | awk '{{gsub(",",""); gsub("\\\"",""); print $3}}')
                 IMAGE_ID=$(aws ec2 describe-images --profile some_profile --filter "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}')
                 aws ec2 deregister-image --profile some_profile --image-id $IMAGE_ID
                 aws ec2 create-image --profile some_profile  --instance-id $INSTANCE_ID --name "$SBE_BASE" --description "$IMAGE_DESCRIPTION"
                 echo "Image created, AMI ID is saved to $SBE_AMI_ID $(aws ec2 describe-images --profile some_profile --filters "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}' > $SBE_AMI_ID)"
                 else
                     INSTANCE_ID=$(terraform output | grep instance_id | awk '{{gsub(",",""); gsub("\\\"",""); print $3}}')
                     aws ec2 create-image --profile some_profile  --instance-id $INSTANCE_ID --name "$SBE_BASE" --description "$IMAGE_DESCRIPTION"
                            fi
        terraform destroy -auto-approve
        echo "Image created, AMI ID is saved to $SBE_AMI_ID $(aws ec2 describe-images --profile some_profile --filters "Name=name,Values=$SBE_BASE" | grep ami- | awk '{{gsub(",",""); gsub("\\\"",""); print $2}}' > $SBE_AMI_ID)"
fi