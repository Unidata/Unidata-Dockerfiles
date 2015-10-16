#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

/usr/sbin/rsyslogd

ldmadmin start
