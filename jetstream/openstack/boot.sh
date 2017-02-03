#!/bin/bash

usage="$(basename "$0") [-h] [-n, --name vm name] [-s, --size vm size] [-ip, --ip ip address] -- 
script to setup VMs.:\n
    -h  show this help text\n
    -n, --name vm name.\n
    -s, --size vm size\n
    -ip, --ip vm ip number\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -n|--name)
            VM_NAME="$2"
            shift # past argument
            ;;
        -s|--size)
            VM_SIZE="$2"
            shift # past argument
            ;;
        -ip|--ip)
            IP="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z ${VM_NAME+x} ];
  then
      echo "Must supply a vm name:" 
      echo -e $usage
      exit 1
fi

if [ -z ${VM_SIZE+x} ];
   then
      echo "Must supply a vm size:" 
      echo -e $usage
      nova flavor-list
      exit 1
fi

if [ -z ${IP+x} ];
   then
      echo "Must supply an IP address:"
      echo -e $usage
      nova floating-ip-list
      exit 1
fi

MACHINE_NAME=${OS_PROJECT_NAME}-${VM_NAME}

nova boot ${MACHINE_NAME} \
--flavor ${VM_SIZE} \
--image 1c997f2c-bae9-4b53-9197-2948cd449405 \
--key-name ${OS_PROJECT_NAME}-api-key \
--security-groups global-ssh \
--nic net-name=${OS_PROJECT_NAME}-api-net

# give chance for VM to fire up
echo sleep 30 && sleep 30

nova add-secgroup ${MACHINE_NAME} global-ssh
nova add-secgroup ${MACHINE_NAME} global-http
nova add-secgroup ${MACHINE_NAME} global-ldm
nova add-secgroup ${MACHINE_NAME} global-adde
nova add-secgroup ${MACHINE_NAME} global-ssl
nova add-secgroup ${MACHINE_NAME} global-tomcat-http
nova add-secgroup ${MACHINE_NAME} global-tomcat-ssl

nova floating-ip-associate ${MACHINE_NAME} ${IP}
