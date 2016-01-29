#!/bin/bash

set -e
set -x
trap "echo TRAPed signal" HUP INT QUIT KILL TERM

###
# McIDAS environment variables
###

HOME=/home/mcidas
MCHOME=$HOME
McINST_ROOT=$MCHOME
MCDATA=$MCHOME/upcworkdata
export HOME MCHOME McINST_ROOT MCDATA

# CD to the MCHOME directory
cd $MCHOME

# Unpack the McIDAS source distribution file
sh ./mcunpack

# Source the mcidas_env.sh environment variable setting script
# to set macros like CC, FC, etc. before attempting a build
source ./admin/mcidas_env.sh

# OK, let's build and install the ADDE portion of McIDAS
cd mcidas2015/src
make -f makefile.adde adde
make -f makefile.adde rootdirs
make -f makefile.adde install.adde

# Clean-up after the build/install
cd $MCHOME
rm -rf mcidas2015
rm -f mcidasx2015.tar.gz mcunpack mcinet2015.sh

# Finishing touches for ADDE remote serving
cp -p admin/mcadde_mlode.ksh .mcenv
chmod 666 .mcenv
