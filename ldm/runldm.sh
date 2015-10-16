#!/bin/bash

set -e
set -x
export PATH=/home/ldm/bin:$PATH
trap "echo TRAPed signal" HUP INT QUIT KILL TERM

/usr/sbin/rsyslogd

ldmadmin mkqueue -f
ldmadmin start
ldmadmin watch

#sleep 10

#echo ""
#echo ""
#echo "Hit [RETURN] to exit"
#read
