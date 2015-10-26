#!/bin/bash

usage="$(basename "$0") [-h --help] [-e, --etc-dir] [-d, --data-dir] [-l, --logs-dir]\n
script to start LDM Docker container where:\n
-h, --help  show this help text\n
-e, --etc-dir The LDM etc directory\n
-d, --data-dir The LDM data directory\n
-l, --logs-dir The LDM logs directory\n"

PWD=`pwd`

ETC_DIR=${PWD}

DATA_DIR=${PWD}

LOGS_DIR=${PWD}

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -e|--etc-dir)
            ETC_DIR="$2"
            shift # past argument
            ;;
        -d|--data-dir)
            DATA_DIR="$2"
            shift # past argument
            ;;
        -l|--logs-dir)
            LOGS_DIR="$2"
            shift # past argument
            ;;
        -h|--help)
            echo $usage
            exit
            ;;
    esac
    shift # past argument or value
done

docker run -i -t \
       -v ${ETC_DIR}:/home/ldm/etc \
       -v ${DATA_DIR}:/home/ldm/var/data \
       -v ${LOGS_DIR}:/home/ldm/var/logs \
       unidata/ldm
