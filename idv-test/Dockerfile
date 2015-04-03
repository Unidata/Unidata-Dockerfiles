FROM unidata:idv-gui

COPY starttest.sh /home/idv/

RUN mkdir ~/test-output

RUN curl -SL \
   https://motherlode.ucar.edu/repository/entry/get/RAMADDA/IDV%20Community%20Resources/Test%20Data/data.tar.bz2?entryid=db269509-bfba-4c2e-b94f-5a0484a0f022 \
  -o /tmp/data.tar.bz2

RUN tar xvfj /tmp/data.tar.bz2 -C /tmp

ADD test-bundles /home/idv/test-bundles

