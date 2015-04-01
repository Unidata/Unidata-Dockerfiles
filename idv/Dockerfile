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

RUN apt-get install -y man nano
RUN apt-get install -y x11-utils x11-common x11vnc xvfb xinit
RUN apt-get install -y fluxbox


###
# Set up a non-root user account.
###

RUN useradd -ms /bin/bash dockuser
RUN adduser dockuser sudo
RUN echo 'dockuser:docker' | chpasswd
USER dockuser
ENV HOME /home/dockuser
WORKDIR /home/dockuser

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
# Copy IDV tarball over to the new user.
###

ADD IDV5.tar.bz2 /home/dockuser

###
# Include Dockerfile,
# utility script to run the IDV
# just for ease of use.
###

COPY Dockerfile /home/dockuser
COPY run_idv.sh /home/dockuser

###
# Configure fluxbox.
###

RUN mkdir ~/.fluxbox/
RUN bash -c 'echo "xterm &" >> ~/.fluxbox/startup'
RUN echo "/usr/bin/fluxbox -log ~/.fluxbox/log &" >> ~/.fluxbox/startup
RUN bash -c 'echo "/home/dockuser/IDV5/runIDV && shutdown -h now" >> ~/.fluxbox/startup'



ENV APORT 5901
EXPOSE 5901
CMD ["xinit", "--", "/usr/bin/Xvfb", ":1", "-screen", "0", "1024x768x24"]
