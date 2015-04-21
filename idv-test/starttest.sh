#!/bin/bash

xinit -- /usr/bin/Xvfb :1 -screen 0 $SIZEH\x$SIZEW\x$CDEPTH &
sleep 5
export DISPLAY=localhost:1 
#/home/idv/IDV/testIDV ~/test-bundles/addeimage1.xidv ~/test-output/results

for file in test-bundles/* ; do
    echo TESTING $file
    /home/idv/IDV/testIDV $file ~/test-output/results
done

cp /tmp/baseline/* ~/test-output/baseline

python compare.py
