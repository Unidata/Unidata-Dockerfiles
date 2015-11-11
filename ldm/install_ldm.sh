#!/bin/bash

set -x

# Run RSyslog daemon
/usr/sbin/rsyslogd

v=6.12.14

wget ftp://ftp.unidata.ucar.edu/pub/ldm/ldm-${v}.tar.gz

gunzip -c ldm-${v}.tar.gz | pax -r '-s:/:/src/:'

cd /home/ldm/ldm-${v}/src

while [ ! -S /dev/log ]; do
    sleep 5
done

./configure --disable-root-actions

make install > make.log 2>&1

sudo make root-actions

# optional
# make distclean

cd /home/ldm

rm ldm-${v}.tar.gz

tar cvfj /tmp/output/ldm-${v}.tar.bz2 .

cp /etc/rsyslog.conf /tmp/output
