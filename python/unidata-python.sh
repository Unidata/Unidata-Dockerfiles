#!/bin/bash

usage="$(basename "$0") [-h] [-v, --volume directory] [-p, --port port] -- 
script to start Unidata Python Docker container where:\n
    -h  show this help text\n
    -v, --volume A local host dicrectory that will be bound to the 
/home/python/work direcotry. The default is the PWD.\n
    -p, --port  Forward port 8888 to the specified port. Useful for running
IPyNB, for example.\n"

# Set some defaults

VOLUME=`pwd`

PORT=9321

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

docker run -i -t -v "${VOLUME}":/home/python/work -p "${PORT}":8888 \
    unidata/python
