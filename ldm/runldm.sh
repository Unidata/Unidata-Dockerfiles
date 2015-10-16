#!/bin/bash

set -e
set -x
export PATH=/home/ldm/bin:$PATH
trap "echo TRAPed signal" HUP INT QUIT KILL TERM

mkdir -p /home/ldm/var/queues/

/usr/sbin/rsyslogd

ldmadmin mkqueue
ldmadmin start
