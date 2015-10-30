FROM tomcat:8
MAINTAINER Sean Arms <sarms@ucar.edu>
#
# Expose ports 8080 (tomcat) and 8443 (tomcat ssl)
#
EXPOSE 8080 8443

#
# Install netcdf and some basic command line tools
#
#RUN apt-get update && apt-get install -y \
#  less \
#  libnetcdf-dev \
#  vim 

#
# Create the user and group tomcat and change ownershiup of the tomcat
#   directory to user and group tomcat
#
RUN groupadd -r tomcat -g 1000 && \
useradd -u 1000 -r -g tomcat -d ${CATALINA_HOME} -s /bin/bash -c "User tomcat for Docker image" tomcat

#
# Copy over modified tomcat files
#
COPY tomcat-files/bin/setenv.sh ${CATALINA_HOME}/bin/setenv.sh
COPY tomcat-files/conf/server.xml ${CATALINA_HOME}/conf/server.xml
COPY tomcat-files/conf/tomcat-users.xml ${CATALINA_HOME}/conf/tomcat-users.xml
COPY tomcat-files/conf/keystore ${CATALINA_HOME}/conf/keystore

#
# Copy over bash_profile file that sets correct umask for sharing
#
# Copy over bash_logout file that nicely closes java processes for
#  shutting down
#
COPY tomcat-files/bash_profile ${CATALINA_HOME}/.bash_profile
COPY tomcat-files/bash_logout ${CATALINA_HOME}/.bash_logout

#
# get the latest stable THREDDS Data Server (TDS)
#
#RUN wget -O ${CATALINA_HOME}/webapps/thredds##04.06.02.war https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tds/4.6.2/tds-4.6.2.war

#
# Copy thredds.war
#
COPY thredds.war ${CATALINA_HOME}/webapps/thredds##04.06.04-SNAPSHOT.war

#
# Change owner of tomcat directory to user and group tomcat
#
RUN chown -R tomcat:tomcat ${CATALINA_HOME} 

#
# Switch to user tomcat
#
USER tomcat
