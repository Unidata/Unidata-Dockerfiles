#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

bash ~/git/Unidata-Dockerfiles/jetstream/openstack/mount.sh -m /dev/sdb \
     -d /data
bash ~/git/Unidata-Dockerfiles/jetstream/openstack/mount.sh -m /dev/sdc \
     -d /repository

# ensure disks reappear on startup
echo /dev/sdb   /data   ext4  rw      0 0 | tee --append /etc/fstab > /dev/null
echo /dev/sdc   /repository   ext4  rw      0 0 | tee --append /etc/fstab > /dev/null
