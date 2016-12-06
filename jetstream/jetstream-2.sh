#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

bash ~/git/Unidata-Dockerfiles/jetstream/openstack/mount.sh -m /dev/sdb \
     -d /data
bash ~/git/Unidata-Dockerfiles/jetstream/openstack/mount.sh -m /dev/sdc \
     -d /repository
