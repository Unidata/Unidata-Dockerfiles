#!/bin/bash
mkdir -p ~/git
git clone https://github.com/Unidata/Unidata-Dockerfiles \
    ~/git/Unidata-Dockerfiles
git clone https://github.com/Unidata/TdsConfig ~/git/TdsConfig

mkdir -p ~/logs/ldm/ ~/logs/ramadda-tomcat/ ~/logs/ramadda/ ~/logs/tds-tomcat/ \
      ~/logs/tds/ ~/logs/traefik/ ~/logs/tdm/

mkdir -p ~/etc
cp -r ~/git/Unidata-Dockerfiles/jetstream/etc/* ~/etc/

sed -i \
    s/server\ 0.ubuntu.pool.ntp.org/server\ timeserver.unidata.ucar.edu\\nserver\ 0.ubuntu.pool.ntp.org/g \
    /etc/ntp.conf

mkdir -p ~/tdsconfig/ ~/etc/TDS
cp ~/git/TdsConfig/idd/config.zip ~/tdsconfig/
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
cp -r ~/tdsconfig/pqacts/* ~/etc/TDS

# in place change of logs dir w/ sed

sed -i s/logs\\/ldm-mcidas.log/var\\/logs\\/ldm-mcidas\\.log/g \
    ~/etc/TDS/util/ldmfile.sh

chmod +x ~/etc/TDS/util/ldmfile.sh

# Create RAMADDA default password

echo ramadda.install.password=changeme! | tee --append \
  /repository/pw.properties > /dev/null

cp ~/git/Unidata-Dockerfiles/jetstream/mcidas/pqact.conf_mcidasA ~/etc
mkdir -p ~/mcidas/upcworkdata/ ~/mcidas/decoders/ ~/mcidas/util/
cp ~/git/Unidata-Dockerfiles/mcidas/RESOLV.SRV ~/mcidas/upcworkdata/

openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=tomcat.example.com" \
  -keyout ~/git/Unidata-Dockerfiles/jetstream/files/ssl.key \
  -out ~/git/Unidata-Dockerfiles/jetstream/files/ssl.crt

curl -SL  \
     https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tdmFat/4.6.6/tdmFat-4.6.6.jar \
     -o ~/logs/tdm/tdm.jar
curl -SL https://raw.githubusercontent.com/Unidata/thredds-docker/master/tdm/tdm.sh \
     -o ~/logs/tdm/tdm.sh
chmod +x  ~/logs/tdm/tdm.sh
