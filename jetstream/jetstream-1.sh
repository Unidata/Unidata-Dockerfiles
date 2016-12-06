#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

bash ~/git/Unidata-Dockerfiles/docker-vm-setup/ubuntu/setup-ubuntu.sh -u ubuntu \
     -dc 1.8.1

reboot now
