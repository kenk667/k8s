#!/bin/bash
#!/usr/bin/env bash

#Assumptions are made that ./snowballEdge configure has been run and the device IP, manifest, and unlock code set up. If that hasn't been done, this script will fail on the first ./snowballEdge command

set -x
set -e

while true; do
    read -p "Do you have an IP set for the SBE? Y/N?" yn
    case $yn in
        [Yy]* ) read -p "What's assigned IP? " DEVICE_IP; break;;
        [Nn]* ) echo "Go set the IP on the SBE, exiting"; exit;;
        * ) echo "Please answer yes(Y/y) or no(N/n).";;
    esac
done

while true; do
    read -p "Have you run ./snowballEdge configure? Script needs SBE CLI configuration completed for it to work! Y/N? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "setup SBE CLI, exiting"; exit;;
        * ) echo "Please answer yes(Y/y) or no(N/n).";;
    esac
done

while true; do
    read -p "Do you have the manifest file in the SBE CLI directory? Y/N?" yn
    case $yn in
        [Yy]* ) read -p "What's the manifest file name? " MANIFEST; break;;
        [Nn]* ) echo "Go download manifest file and unlock code, exiting"; exit;;
        * ) echo "Please answer yes(Y/y) or no(N/n).";;
    esac
done

while true; do
    read -p "Do you have the unlock code? Y/N?" yn
    case $yn in
        [Yy]* ) read -p "What's unlock code? " UNLOCK; break;;
        [Nn]* ) echo "Go download manifest file and unlock code, exiting"; exit;;
        * ) echo "Please answer yes(Y/y) or no(N/n).";;
    esac
done

pushd ../snowball_client/1.0.1/bin/

popd

if ./snowballEdge describe-device | grep UNLOCKED; then
        echo "SBE is already unlocked, exiting"
        exit 0
else
        ./snowballEdge unlock-device --endpoint https:${DEVICE_IP} --manifest-file ${MANIFEST} --unlock-code ${UNLOCK}
fi