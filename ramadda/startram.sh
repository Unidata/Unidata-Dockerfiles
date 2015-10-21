#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

catalina.sh run
