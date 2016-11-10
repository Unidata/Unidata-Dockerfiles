###
# Dockerfile that contains Unidata Python and ancillary technology (e.g.,IPyNB)
###

FROM ubuntu:16.10

MAINTAINER Unidata Cloud Team

###
# anaconda works better with bash
###

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

###
# House keeping
###

RUN apt-get update

RUN apt-get -y upgrade

###
# Install some Linux packages
###

RUN apt-get install -y curl git bzip2 sudo

###
# In case the user wants to run a IPyNB
###

EXPOSE 8888

###
# Set up python user account
###

RUN useradd -ms /bin/bash python

RUN adduser python sudo

RUN echo "python ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN echo 'python:docker' | chpasswd

USER python

ENV HOME /home/python

WORKDIR $HOME

###
# Install miniconda
###

RUN mkdir -p $HOME/downloads

RUN cd $HOME/downloads && curl -SL \
  http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o \
  Miniconda3-latest-Linux-x86_64.sh

RUN /bin/bash $HOME/downloads/Miniconda3-latest-Linux-x86_64.sh -b -p \
  $HOME/anaconda/

ENV PATH $HOME/anaconda/bin:$PATH

RUN conda update --yes --quiet conda

ADD environment.yml $HOME/

RUN conda env update --name root -f $HOME/environment.yml

###
# Work volume
###

RUN mkdir -p $HOME/work

WORKDIR $HOME/work

VOLUME $HOME/work

###
# Wrapping up some stuff
###

USER root

RUN rm -rf $HOME/downloads/*

RUN chown -R python:python $HOME/

###
# Start container
###

USER python

ADD .bashrc $HOME/

ADD login-msg.txt $HOME/

CMD bash

