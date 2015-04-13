FROM unidata:idv-gui

COPY starttest.sh /home/idv/

RUN mkdir ~/test-output

RUN curl -SL \
   http://motherlode.ucar.edu/repository/entry/get/RAMADDA/IDV%20Community%20Resources/Test%20Data/data.tar.bz2?entryid=f024f354-6cca-45ba-aac5-e06143db5b54 \
  -o /tmp/data.tar.bz2

RUN tar xvfj /tmp/data.tar.bz2 -C /tmp

ADD test-bundles /home/idv/test-bundles

