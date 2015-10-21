#!/bin/bash

set -e

trap "echo TRAPed signal" HUP INT QUIT KILL TERM

$DATA_DIR/catalina.sh run
