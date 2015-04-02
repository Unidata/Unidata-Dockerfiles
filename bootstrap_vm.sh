#!/bin/bash

#####
# Update package list, install some default packages.
#####
apt-get update
apt-get -y upgrade
apt-get install -y git curl emacs

#####
# Install docker.io, using instructions from:
# https://docs.docker.com/installation/ubuntulinux/
#####
curl -sSL https://get.docker.com/ubuntu/ | sudo sh

##
# Allow for non-root access.
##
sudo gpasswd -a vagrant docker
sudo service docker restart

##
# Set up a readme
##
TFILE=/home/vagrant/DOCKER_NOTES.md
SFILE=/vagrant/NOTES.md

if [ -f $SFILE ]; then
    cp $SFILE $TFILE
fi

##
# Download the IDV file used by
# the dockerfile, if need be.
##
if [ ! -f /vagrant/dockerfile-idv/IDV5.tar.bz2 ]; then
    curl -O ftp://ftp.unidata.ucar.edu/pub/netcdf/IDV5.tar.bz2
    mv IDV5.tar.bz2 /vagrant/dockerfile-idv/
fi


#####
# Cleanup
#####
chown -R vagrant:vagrant /home/vagrant
