#!/bin/bash
#
# Convienence script to launch a docker container version of the IDV with all of the appropriate arguments.


if [ $# -ne 2 ]
then
    echo "Syntax: $(basename $0) <docker image> <output dir>"
    exit 1
fi

set -x

docker run -v $2:/home/idv/test-output -p 5901:5901 --rm -it $1 /home/idv/starttest.sh
