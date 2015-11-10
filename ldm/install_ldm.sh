#!/bin/sh

# Create spool directory
mkdir -p /var/spool/rsyslog

# Run RSyslog daemon
exec /usr/sbin/rsyslogd &

v=6.12.14

wget ftp://ftp.unidata.ucar.edu/pub/ldm/ldm-${v}.tar.gz

gunzip -c ldm-${v}.tar.gz | pax -r '-s:/:/src/:'

cd /home/ldm/ldm-${v}/src

./configure --disable-root-actions

make install >make.log 2>&1

make root-actions

make distclean

cd /home/ldm

rm ldm-${v}.tar.gz

rm install_ldm.sh

tar cvfj /tmp/output/ldm.tar.bz2 .

cp /etc/rsyslog.conf /tmp/output
