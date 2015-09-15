# See https://www.unidata.ucar.edu/software/ldm/ldm-current/basics/platform.html

FROM ubuntu

RUN apt-get update

RUN apt-get -y upgrade

RUN apt-get install -y wget pax gcc zlib1g-dev libxml2-dev make libpng-dev rsyslog

# rsyslog

ADD rsyslog.conf /etc/

# port for rsyslog
EXPOSE 514

EXPOSE 514/udp

# Set up ldm directory

RUN mkdir /home/ldm

ENV HOME /home/ldm

WORKDIR /home/ldm

# Install the ldm

COPY install_ldm.sh /home/ldm/

CMD bash -C '/home/ldm/install_ldm.sh';'bash'
