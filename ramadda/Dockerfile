###
# Dockerfile for RAMADDA
###

FROM tomcat:jre8

ENV VERSION 2.1b

###
# Usual maintenance
###

RUN apt-get update

RUN apt-get -y install sudo

###
# Grab RAMADDA
###

RUN curl -SL \
  https://motherlode.ucar.edu/repository/entry/get/repository-${VERSION}.war?entryid=21405142-70bb-48f7-88c2-22a828955018 \
  -o webapps/repository.war

ENV DATA_DIR /data/repository

RUN mkdir -p $DATA_DIR

VOLUME $DATA_DIR

ENV JAVA_OPTS -d64 -Xmx4048m -Xms512m \
  -Dorg.apache.catalina.security.SecurityListener.UMASK=0007 -server \
  -Dramadda_home=$DATA_DIR -Dfile.encoding=utf-8

ENV CATALINA_OPTS -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true

###
# Create tomcat user
###

RUN groupadd -r tomcat && \
	useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c \
  "Tomcat user" tomcat && chown -R tomcat:tomcat ${CATALINA_HOME}

RUN echo "tomcat ALL=NOPASSWD: ALL" >> /etc/sudoers

WORKDIR $DATA_DIR

COPY startram.sh ${CATALINA_HOME}/bin/

RUN chown -R tomcat:tomcat /data/repository

USER tomcat

CMD ${CATALINA_HOME}/bin/startram.sh
