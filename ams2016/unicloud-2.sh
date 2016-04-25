#!/bin/bash
set -x

# update and install packages
sudo apt-get -qq update
sudo apt-get -qq upgrade
sudo apt-get -qq install unzip tree

# Add ubuntu to docker group
sudo usermod -G docker ubuntu

# Restart docker service
sudo service docker restart

# Get docker-compose
  curl -L \
  https://github.com/docker/compose/releases/download/1.7.0/\
docker-compose-`uname -s`-`uname -m` > docker-compose
  sudo mv docker-compose /usr/local/bin/
  sudo chmod +x /usr/local/bin/docker-compose

# Get the git repositories we will want to work with
mkdir -p /home/ubuntu/git
git clone https://github.com/Unidata/Unidata-Dockerfiles \
    /home/ubuntu/git/Unidata-Dockerfiles
git clone https://github.com/Unidata/TdsConfig /home/ubuntu/git/TdsConfig

# Create LDM directories
mkdir -p ~/var/logs 
mkdir -p ~/etc/TDS

# Copy various files for the LDM.
cp ~/git/Unidata-Dockerfiles/ldm/etc/netcheck.conf ~/etc

cp ~/git/Unidata-Dockerfiles/ams2016/ldmd.conf ~/etc/

cp ~/git/Unidata-Dockerfiles/ams2016/registry.xml ~/etc/

cp ~/git/Unidata-Dockerfiles/ams2016/scour.conf ~/etc/

# Set up LDM and TDS configuration
mkdir -p ~/tdsconfig/
cp ~/git/TdsConfig/idd/config.zip ~/tdsconfig/
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
cp -r ~/tdsconfig/pqacts/* ~/etc/TDS

# in place change of logs dir w/ sed
sed -i s/logs\\/ldm-mcidas.log/var\\/logs\\/ldm-mcidas\\.log/g \
    ~/etc/TDS/util/ldmfile.sh

chmod +x ~/etc/TDS/util/ldmfile.sh

# use catalog xml files that are consistent with our data holdings
cp -r ~/git/Unidata-Dockerfiles/ams2016/catalogs/* ~/tdsconfig

# Create ADDE directories
mkdir -p ~/decoders
mkdir -p ~/upcworkdata

cp ~/git/Unidata-Dockerfiles/mcidas/RESOLV.SRV ~/etc/

cp ~/git/Unidata-Dockerfiles/ams2016/pqact.conf_mcidasA ~/etc/

# Set up data directories
sudo ln -s /mnt /data
sudo mkdir /mnt/ldm/
sudo chown -R ubuntu:docker /data/ldm
sudo mkdir /home/ubuntu/repository/
sudo chown -R ubuntu:docker /home/ubuntu/repository

# Create Tomcat logging directories
mkdir -p ~/logs/ramadda-tomcat
mkdir -p ~/logs/tds-tomcat

# Create RAMADDA default password
echo ramadda.install.password=changeme! > \
  /home/ubuntu/repository/pw.properties

sudo chown -R ubuntu:docker /home/ubuntu
