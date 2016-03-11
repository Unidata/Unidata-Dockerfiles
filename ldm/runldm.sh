#!/bin/bash

set -e
set -x
export PATH=/home/ldm/bin:$PATH
trap "echo TRAPed signal" HUP INT QUIT KILL TERM

/usr/sbin/rsyslogd

/usr/sbin/crond

ldmadmin delqueue
ldmadmin mkqueue
ldmadmin start

# never exit
while true; do sleep 10000; done

#ldmadmin watch

#sleep 10

#echo ""
#echo ""
#echo "Hit [RETURN] to exit"
#read
