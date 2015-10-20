#!/bin/bash
#
# Utility script that is executed when the Docker image is run.
# Simple now, but can be fleshed out quite a bit.



###
# Show README if HELP environment variable
# is set to anything.
###
if [ "x$HELP" != "x" ]; then
    cat README.md
    exit
fi


bash
