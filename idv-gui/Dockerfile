FROM unidata/idv-base

USER root

RUN apt-get install -y x11vnc xvfb xinit fluxbox

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
# Include Dockerfile,
# utility script to run the IDV
# just for ease of use.
###

COPY Dockerfile /home/idv/
COPY run_idv.sh /home/idv/
###
# Configure fluxbox.
###

RUN mkdir ~/.fluxbox/
RUN bash -c 'echo "xterm &" >> ~/.fluxbox/startup'
RUN echo "/usr/bin/fluxbox -log ~/.fluxbox/log &" >> ~/.fluxbox/startup

ENV APORT 5901
EXPOSE 5901

RUN bash -c 'echo "/home/idv/IDV/runIDV && shutdown -h now" >> ~/.fluxbox/startup'
COPY startidv.sh /home/idv/
CMD ["xinit", "--", "/usr/bin/Xvfb", ":1", "-screen", "0", "1024x768x24"]