#!/bin/bash
#!/usr/bin/env bash

#Assumptions are made that ./snowballEdge configure has been run and the device IP, manifest, and unlock code set up. If that hasn't been done, this script will fail on the first ./snowballEdge command

set -x
set -e

while true; do
    read -p "Have you run ./snowballEdge configure? Script needs SBE CLI configuration completed for it to work! Y/N? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "setup SBE CLI, exiting"; exit;;
        * ) echo "Please answer yes(Y/y) or no(N/n).";;
    esac
done

read -p "Enter the IP address for the virtual interface " IP_ADDR

while true; do
    read -p "Is the network mask 255.255.255.0? Y/N? " yn
    case $yn in
        [Yy]* ) echo "applying class C mask"; NET_MASK="255.255.255.0"; break;;
        [Nn]* ) read -p "Enter the Network Mask for the virtual interface " NET_MASK; break;;
        * ) echo "Please answer yes(Y/y) or no(N/n).";;
    esac
done

#./snowballEdge describe-device | awk '{if(NR==26) {gsub(",",""); gsub("\\\"",""); print $3}}'

PHYSICAL_ID=$(../snowball_client/1.0.1/bin/./snowballEdge describe-device | grep s.ni | awk '{if(FNR==3) {gsub(",",""); gsub("\\\"",""); print $3}}')

pushd ../snowball_client/1.0.1/bin/

if ./snowballEdge describe-virtual-network-interfaces | grep ${PHYSICAL_ID}; then

        echo "Virtual IP has already been configured, here are your virtual networks"
        ./snowballEdge describe-virtual-network-interfaces
        exit 0

else
        echo "Configuring Virtual IP"
        ./snowballEdge create-virtual-network-interface --physical-network-interface-id ${PHYSICAL_ID} --ip-address-assignment STATIC --static-ip-address-configuration IpAddress=${IP_ADDR},Netmask=${NET_MASK}

fi