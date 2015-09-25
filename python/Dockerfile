# Dockerfile that contains Unidata Python and ancillary technology (e.g.,IPyNB)

FROM ubuntu:15.10

MAINTAINER Julien Chastang <chastang@ucar.edu>

# anaconda works better with bash

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# House keeping

RUN apt-get update

RUN apt-get -y upgrade

# Install some Linux packages

RUN apt-get install -y curl git bzip2

# In case the user wants to run a IPyNB

EXPOSE 8888

# Set up python user account

RUN useradd -ms /bin/bash python

RUN adduser python sudo

RUN echo 'python:docker' | chpasswd

USER python

ENV HOME /home/python

WORKDIR /home/python

# Install miniconda

RUN mkdir -p /home/python/downloads

RUN cd /home/python/downloads && curl -SL \
  http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh -o \
  Miniconda-latest-Linux-x86_64.sh

RUN /bin/bash /home/python/downloads/Miniconda-latest-Linux-x86_64.sh -b -p \
  /home/python/anaconda/

ENV PATH /home/python/anaconda/bin:$PATH

RUN conda update --yes --quiet conda

RUN conda config --add channels https://conda.binstar.org/unidata

ADD environment.yml /home/python/

RUN conda env create --quiet /home/python/environment.yml

RUN mkdir -p /home/python/work

WORKDIR /home/python/work

VOLUME /home/python/work

USER root

RUN chown -R python:python /home/python/

USER python
