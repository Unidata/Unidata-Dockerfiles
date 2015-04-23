FROM unidata:idv-gui

###
# Install Python, pip, pyhiccup as root
###

USER root

RUN apt-get install -y python

RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"

RUN python get-pip.py

# A couple of Python HTML conveniences for generating HTML output
RUN pip install pyhiccup html5print

USER idv

###
# Setting up test instructure that will be use by starttest.sh
###

COPY starttest.sh /home/idv/

COPY compare.py /home/idv/

RUN mkdir -p ~/test-output/results

RUN mkdir ~/test-output/baseline

# Grab test data
RUN curl -SL \
   http://motherlode.ucar.edu/repository/entry/get/RAMADDA/IDV%20Community%20Resources/Test%20Data/data.tar.bz2?entryid=f024f354-6cca-45ba-aac5-e06143db5b54 \
  -o /tmp/data.tar.bz2

# Grab baseline images to compare against
RUN curl -SL \
   http://motherlode.ucar.edu/repository/entry/get/RAMADDA/IDV%20Community%20Resources/Test%20Images/baseline.tar.bz2?entryid=58b1f615-9012-4e06-9e1d-9878eb05b554 \
  -o /tmp/baseline.tar.bz2

RUN tar xvfj /tmp/data.tar.bz2 -C /tmp

RUN tar xvfj /tmp/baseline.tar.bz2 -C /tmp

ADD test-bundles /home/idv/test-bundles
