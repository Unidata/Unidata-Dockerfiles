#!/bin/bash

usage="$(basename "$0") [-h --help] [-v, --volume directory] [-p, --port port]\n
-- script to start Unidata Python Docker container where:\n
    -h, --help  show this help text\n
    -v, --volume A local host directory that will be bound to the 
/home/python/work\n directory. The default is the PWD.\n
    -p, --port  Forward port 8888 to the specified port. Useful for running
IPyNB, \nfor example. The default is 8888."


# Set some defaults

VOLUME=`pwd`

PORT=8888

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

# To remove login msg, remove HELP env var below. Could be parameterized.
docker run -e HELP=YES -i -t  -p "${PORT}":8888 \
       -v "${VOLUME}":/home/python/work \
       -v `pwd`/.jupyter:/home/python/.jupyter \
       unidata/python
