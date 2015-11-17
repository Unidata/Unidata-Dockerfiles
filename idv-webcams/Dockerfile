FROM centos:7

###
# Update the system. Install stuff.
###

RUN yum update yum

RUN yum install -y sudo tcl git

###
# Set up idv user account
###

RUN useradd -ms /bin/bash idv

RUN echo "idv ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN echo 'idv:docker' | chpasswd

###
# IDV HOME
###

RUN mkdir -p /opt/bin/webcams/

ENV HOME /opt/bin/webcams/

WORKDIR $HOME

###
# Webcam tcl scripts
###

RUN mkdir -p /data/logs
RUN chown -R idv:idv /data/logs

RUN mkdir -p /georesources/webcams/
RUN chown -R idv:idv /georesources/webcams/

RUN ln -s /usr/bin/tclsh /opt/bin/tclsh

COPY defineImages.tcl /opt/bin/webcams/

COPY getImages.tcl /opt/bin/webcams/

COPY webcams.sh /opt/bin/webcams/

COPY photooverlay.kml /georesources/webcams/

RUN chmod +x /opt/bin/webcams/webcams.sh

RUN chown -R idv:idv /opt/bin/webcams/

USER idv

CMD $HOME/webcams.sh
