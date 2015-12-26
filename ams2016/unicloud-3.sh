#!/bin/bash
set -x

# Docker pull all relavant images
docker pull unidata/ldmtds:latest
docker pull unidata/tdm:latest
docker pull unidata/tds:latest
docker pull unidata/ramadda:latest

# Start up all images
docker-compose -f ~/git/Unidata-Dockerfiles/ams2016/docker-compose.yml up -d
