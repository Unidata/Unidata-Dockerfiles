#!/bin/bash
mkdir -p ~/git
git clone https://github.com/Unidata/Unidata-Dockerfiles \
    ~/git/Unidata-Dockerfiles
git clone https://github.com/Unidata/TdsConfig ~/git/TdsConfig

mkdir -p ~/logs/ldm/ ~/logs/ramadda-tomcat/ ~/logs/ramadda/ ~/logs/tds-tomcat/ \
      ~/logs/tds/ ~/logs/traefik/ ~/logs/tdm/

mkdir -p ~/etc
cp -r ~/git/Unidata-Dockerfiles/jetstream/etc/* ~/etc/

mkdir -p ~/tdsconfig/ ~/etc/TDS
cp ~/git/TdsConfig/idd/config.zip ~/tdsconfig/
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
cp -r ~/tdsconfig/pqacts/* ~/etc/TDS

# Create RAMADDA default password
echo ramadda.install.password=changeme! | sudo tee --append \
  /repository/pw.properties > /dev/null

openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=tomcat.example.com" \
  -keyout ~/git/Unidata-Dockerfiles/jetstream/files/ssl.key \
  -out ~/git/Unidata-Dockerfiles/jetstream/files/ssl.crt

curl -SL  https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tdmFat/4.6.6/tdmFat-4.6.6.jar \
     -o ~/logs/tdm/tdm.jar
curl -SL https://raw.githubusercontent.com/Unidata/thredds-docker/master/tdm/tdm.sh \
     -o ~/logs/tdm/tdm.sh
chmod +x  ~/logs/tdm/tdm.sh
