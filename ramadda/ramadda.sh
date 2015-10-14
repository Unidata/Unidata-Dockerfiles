#!/bin/bash

usage="$(basename "$0") [-h --help] [-v, --volume directory] [-p, --port port]\n
-- script to start RAMADDA Docker container where:\n
    -h, --help  show this help text\n
    -v, --volume A local host directory that will be bound to the RAMADDA data\n
directory, /data/repository (e.g., ~/repository). The default is 
\$PWD/repository.\n
    -p, --port  Forward port 8080 to the specified port. The default is 80."


# Set some defaults

VOLUME=`pwd`/repository

PORT=80

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -v|--volume)
            VOLUME="$2"
            shift # past argument
            ;;
        -p|--port)
            PORT="$2"
            shift # past argument
            ;;
        -h|--help)
            echo $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ ! -d ${VOLUME} ]
  then
    mkdir -p ${VOLUME}
fi

docker run --rm -i -t -p "${PORT}":8080 -v "${VOLUME}":/data/repository \
       unidata/ramadda
