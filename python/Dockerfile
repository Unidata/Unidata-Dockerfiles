###
# Dockerfile that contains Unidata Python and ancillary technology (e.g.,IPyNB)
###

FROM ubuntu:15.10

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

WORKDIR /home/python

###
# Install miniconda
###

RUN mkdir -p /home/python/downloads

RUN cd /home/python/downloads && curl -SL \
  http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh -o \
  Miniconda-latest-Linux-x86_64.sh

RUN /bin/bash /home/python/downloads/Miniconda-latest-Linux-x86_64.sh -b -p \
  /home/python/anaconda/

ENV PATH /home/python/anaconda/bin:$PATH

RUN conda update --yes --quiet conda

ADD environment.yml /home/python/

RUN conda env update --name root -f /home/python/environment.yml

###
# Work volume
###

RUN mkdir -p /home/python/work

WORKDIR /home/python/work

VOLUME /home/python/work

###
# Wrapping up some stuff
###

USER root

RUN rm -rf /home/python/downloads/*

RUN chown -R python:python /home/python/

###
# Start container
###

USER python

ADD .bashrc /home/python/

