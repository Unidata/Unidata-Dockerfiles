#!/bin/sh
source ./swarmid.sh
docker-machine create -d amazonec2 --engine-label kind=hub --swarm --swarm-master --swarm-discovery $SWARMID jupyterhub
docker-machine create -d amazonec2 --engine-label kind=notebook --amazonec2-instance-type "t2.large" --swarm --swarm-discovery $SWARMID jupyter1
