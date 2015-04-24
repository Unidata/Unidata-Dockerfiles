#!/bin/bash
#
# Convienence script to launch a docker container version of the IDV with all of the appropriate arguments.

# Note: If running with boot2docker, the output dir may have to be at or below ~

if [ $# -ne 1 ]
then
    echo "Syntax: $(basename $0) <output dir>"
    exit 1
fi

set -x

r=$1/results
b=$1/baseline

if [ ! -d $r ]; then
    mkdir -p $r
fi

if [ ! -d $b ]; then
    mkdir -p $b
fi

docker run -v $1:/home/idv/test-output -p 5901:5901 --rm -it unidata/idv-test /home/idv/starttest.sh
