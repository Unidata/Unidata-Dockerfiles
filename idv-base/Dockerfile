#####
# Used to generate the 'unidata/idv' docker container.
# Visit us on the web at http://www.unidata.ucar.edu
#####

#####
# Common stuff goes at the front,
# so that we can take advantage of the
# shared layers that docker provides.
#####

FROM ubuntu:utopic

RUN apt-get update
RUN apt-get -y upgrade

###
# Install some basics.
###

RUN apt-get install -y man nano curl
RUN apt-get install -y x11-utils x11-common x11vnc xvfb xinit
RUN apt-get install -y fluxbox


###
# Set up a non-root user account.
###

RUN useradd -ms /bin/bash idv
RUN adduser idv sudo
RUN echo 'idv:docker' | chpasswd
USER idv
ENV HOME /home/idv
WORKDIR /home/idv

###
# Configure vnc, xvfb.
# Taken from https://docs.docker.com/reference/builder/#entrypoint
###

RUN mkdir ~/.vnc
RUN x11vnc -storepasswd 1234 ~/.vnc/passwd

###
# Create a .xinitrc file.
#
# The environmental variable APORT = 5901 by default but can be
# overridden when invoking 'docker run', e.g.
#   $ docker run -e APORT=4435
###
RUN echo '/usr/bin/x11vnc -usepw -display :1 -autoport $APORT -forever &' >> ~/.xinitrc
RUN echo "/usr/bin/startfluxbox" >> ~/.xinitrc

###
# Download IDV
###

RUN curl -SL \
  https://motherlode.ucar.edu/repository/entry/get/RAMADDA/IDV%20Community%20Resources/IDV%20Docker/IDV.tar.bz2?entryid=43e9a4b1-269a-4aca-8f63-0800870a9a18 \
  -o ~/IDV.tar.bz2

RUN tar xvfj ~/IDV.tar.bz2

###
# Include Dockerfile,
# utility script to run the IDV
# just for ease of use.
###

COPY Dockerfile /home/idv/

###
# Configure fluxbox.
###

RUN mkdir ~/.fluxbox/
RUN bash -c 'echo "xterm &" >> ~/.fluxbox/startup'
RUN echo "/usr/bin/fluxbox -log ~/.fluxbox/log &" >> ~/.fluxbox/startup

ENV APORT 5901
EXPOSE 5901
CMD ["xinit", "--", "/usr/bin/Xvfb", ":1", "-screen", "0", "1024x768x24"]
