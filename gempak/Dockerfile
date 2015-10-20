#####
# Dockerfile configuration for Unidata
# Gempak Docker image.
#####

FROM centos

###
# Update package manager, install a few things.
###
RUN yum update yum

RUN yum install -y wget csh openmotif openmotif-devel gcc gcc-c++ gcc-gfortran \
	zlib-devel bzip2 libX11-devel libXt-devel libXext libXp-devel \
	libXft-devel libXtst-devel xorg-x11-xbitmaps flex byacc -y

###
# Set up gempak directory
###
RUN mkdir /home/gempak
ENV HOME /home/gempak
WORKDIR /home/gempak

###
# Set up the output directory
###
RUN mkdir /tmp/output

###
# Install GEMPAK,
# set up some stuff in bashrc.
###

COPY install_gempak.sh /home/gempak/
RUN /home/gempak/install_gempak.sh
RUN echo '. /home/gempak/NAWIPS/Gemenviron.profile' >> ~/.bashrc

###
# Copy some other files over.
###
COPY Dockerfile /home/gempak/
COPY rungempak.sh /home/gempak/
COPY README.md /home/gempak/

###
# Set up some default environmental
# variables.
###

ENV HELP ""

###
# Execute command
###
CMD /home/gempak/rungempak.sh
