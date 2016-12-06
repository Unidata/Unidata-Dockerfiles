#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

usage="$(basename "$0") [-h] [-u, --user user name] [-dc, --dc docker-compose version] -- 
script to setup docker. Run as root:\n
    -h  show this help text\n
    -u, --user User name on the docker VM. Will be created if user does not exist.\n
    -dc, --dc docker-compose version you wish to install\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -u|--user)
            DOCKER_USER="$2"
            shift # past argument
            ;;
        -dc|--dc)
            DOCKER_COMPOSE_VERSION="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z ${DOCKER_USER+x} ];
  then
      echo "Must supply a user:" 
      echo -e $usage
      exit 1
fi

if [ -z ${DOCKER_COMPOSE_VERSION+x} ];
   then
      echo "Must supply a docker compose version:" 
      echo -e $usage
      exit 1
fi

###
# update and install a few things
###

RUN yum update yum

yum install -y git unzip zip

###
# https://docs.docker.com/engine/installation/linux/centos/
###

cat ./docker-repo.centos >> /etc/yum.repos.d/docker.repo

yum install docker-engine

groupadd docker

if id "$DOCKER_USER" >/dev/null 2>&1; then
        echo "$DOCKER_USER exists"
else
        useradd -m $DOCKER_USER && chsh -s /bin/bash $DOCKER_USER
fi

usermod -aG docker $DOCKER_USER

systemctl enable docker.service

systemctl start docker

###
# docker-compose
###

curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

###
# Finalizing
###

echo 'sudo reboot now' and log back in with user $DOCKER_USER

echo If the docker service does not restart, consider deleting /var/lib/docker/aufs/

echo Think before you delete the aufs directory

echo Test with 'docker run hello-world'
