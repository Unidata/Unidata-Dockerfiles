#!/bin/sh

v=7.2.2

wget http://www.unidata.ucar.edu/downloads/gempak/latest/gempak-${v}-1.x86_64.rpm

rpm -ivh gempak-${v}-1.x86_64.rpm

rm gempak-${v}-1.x86_64.rpm

rm install_gempak.sh
