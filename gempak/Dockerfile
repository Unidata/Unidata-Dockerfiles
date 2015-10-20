FROM centos

RUN yum update yum

RUN yum install -y wget csh openmotif openmotif-devel gcc gcc-c++ gcc-gfortran \
	zlib-devel bzip2 libX11-devel libXt-devel libXext libXp-devel \
	libXft-devel libXtst-devel xorg-x11-xbitmaps flex byacc -y

# Set up gempak directory

RUN mkdir /home/gempak

ENV HOME /home/gempak

WORKDIR /home/gempak

# Output directory

RUN mkdir /tmp/output

# Install GEMPAK

COPY install_gempak.sh /home/gempak/
COPY Dockerfile /home/gempak/
RUN /home/gempak/install_gempak.sh 
RUN echo '. /home/gempak/NAWIPS/Gemenviron.profile' >> ~/.bashrc
CMD bash
