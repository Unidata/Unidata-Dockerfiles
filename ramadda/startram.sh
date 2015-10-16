#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

sudo /etc/init.d/syslogd start

$DATA_DIR/catalina.sh run
