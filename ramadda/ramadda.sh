#!/bin/bash

if [ ! -d ~/repository]
  then
    mkdir -p ~/repository
fi

docker run --rm -i -t -p 80:8080 -v ~/repository:/data/repository unidata/ramadda:latest
