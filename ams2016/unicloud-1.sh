#!/bin/bash
set -x 

usage="$(basename "$0") [-h] [--azure-host] [--azure-host] [--azure-subscription-id] [--azure-subscription-cert] [--azure-size] -- script to set up Azure Docker Host:\n
    -h  show this help text\n
    --azure-host name of Docker host on Azure\n
    --azure-subscription-id Azure subscription ID\n
    --azure-subscription-cert Azure subscription (.pem) certificate\n
    --azure-size name of Docker host on Azure\n"

AZURE_HOST=unidata-server
AZURE_ID="3.14"
AZURE_CERT="/path/to/cert.pm"
AZURE_SIZE="ExtraLarge"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        --azure-host)
            AZURE_HOST="$2"
            shift # past argument
            ;;
        --azure-subscription-id)
            AZURE_ID="$2"
            shift # past argument
            ;;
        --azure-subscription-cert)
            AZURE_CERT="$2"
            shift # past argument
            ;;
        --azure-size)
            AZURE_SIZE="$2"
            shift # past argument
            ;;
        -h|--help)
            echo $usage
            exit
            ;;
    esac
    shift # past argument or value
done

# Create Azure VM via docker-machine
docker-machine -D create -d azure \
               --azure-subscription-id=$AZURE_ID \
               --azure-subscription-cert=$AZURE_CERT \
               --azure-size=$AZURE_SIZE $AZURE_HOST

# Ensure docker commands will be run with new host
eval "$(docker-machine env $AZURE_HOST)"

# immediately restart VM, according to Azure
docker-machine restart $AZURE_HOST
# Again, ensure docker commands will be run with new host
eval "$(docker-machine env $AZURE_HOST)"
