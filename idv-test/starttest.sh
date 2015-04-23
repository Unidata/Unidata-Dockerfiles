#!/bin/bash

xinit -- /usr/bin/Xvfb :1 -screen 0 $SIZEH\x$SIZEW\x$CDEPTH &
sleep 5
export DISPLAY=localhost:1 
#/home/idv/IDV/testIDV ~/test-bundles/addeimage1.xidv ~/test-output/results

# Kludge to ensure we are testing the nightly

curl -SL https://www.unidata.ucar.edu/software/idv/nightly/webstart/IDV/idv.jar -o /home/idv/IDV/idv.jar
curl -SL https://www.unidata.ucar.edu/software/idv/nightly/webstart/IDV/visad.jar -o /home/idv/IDV/visad.jar
curl -SL https://www.unidata.ucar.edu/software/idv/nightly/webstart/IDV/ncIdv.jar -o /home/idv/IDV/ncIdv.jar

for file in test-bundles/* ; do
    echo TESTING $file
    /home/idv/IDV/testIDV $file ~/test-output/results
done

cp /tmp/baseline/* ~/test-output/baseline

python compare.py
