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

pushd ../snowball_client/1.0.1/bin/

CERT_ARN=$(./snowballEdge list-certificates | grep arn | awk '{gsub(",",""); gsub("\\\"",""); print$3}')

./snowballEdge get-certificate --certificate-arn ${CERT_ARN} > ../../../ca-bundle.pem

popd

chmod 660 ../ca-bundle.pem

aws configure set snowballEdge.ca_bundle ../ca-bundle.pem

echo "sbe_cert.pem created in SBE main TF dir"

echo "your certificate contains the following information "

openssl x509 -in ../ca-bundle.pem -noout -text

exit 0
