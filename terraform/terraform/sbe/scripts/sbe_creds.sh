#!/bin/bash
#!/usr/bin/env bash

#Assumptions are made that ./snowballEdge configure has been run and the device IP, manifest, and unlock code set up. If that hasn't been done, this script will fail on the first ./snowballEdge command

set -x
set -e

while true; do
    read -p "Have you run ./snowballEdge configure? Script needs SBE CLI configuration completed for it to work! Y/N?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "setup SBE CLI, exiting"; exit;;
        * ) echo "Please answer yes(Y/y) or no(N/n).";;
    esac
done

if ls -a $HOME/.aws | grep credentials; then

        export AWS_SHARED_CREDENTIALS_FILE="$HOME/.aws/credentials"
        echo $AWS_SHARED_CREDENTIALS_FILE

else
        echo "AWS CLI isn't configured, set up with command: aws configure, exiting. https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html"
        exit 0
fi

pushd ../snowball_client/1.0.1/bin/

SBE_KEY=$(./snowballEdge list-access-keys | grep : | cut -d'"' -f4)

SBE_SECRET=$(./snowballEdge get-secret-access-key --access-key-id ${SBE_KEY} | grep 'aws_secret_access_key' | cut -d' ' -f3)

popd

#grep defaults to 0=true and 1=false where a match returns 0
if cat ${AWS_SHARED_CREDENTIALS_FILE} | grep snowballEdge; then
        #filters for the next line after matching snowballEdge and isolates the third position
        AWS_ACCESS_KEY=$(awk '/snowballEdge/{getline;print $3}' ${AWS_SHARED_CREDENTIALS_FILE})
        #filters for the second line after matching snowballEdge and isolates the third positions
        AWS_SECRET=$(awk '/snowballEdge/{getline;getline;print $3}' ${AWS_SHARED_CREDENTIALS_FILE})
        #replace
        sed -i "s/${AWS_ACCESS_KEY}/${SBE_KEY}/g" ${AWS_SHARED_CREDENTIALS_FILE}
        sed -i "s/${AWS_SECRET}/${SBE_SECRET}/g" ${AWS_SHARED_CREDENTIALS_FILE}
else
        ../snowball_client/1.0.1/bin/./snowballEdge get-secret-access-key --access-key-id ${SBE_KEY} >> ${AWS_SHARED_CREDENTIALS_FILE}
fi