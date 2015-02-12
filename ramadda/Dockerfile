FROM tomcat:jre8

# Grab RAMADDA
RUN curl -SL http://sourceforge.net/projects/ramadda/files/ramadda1.7/repository.war -o webapps/repository.war

ENV DATA_DIR /data/repository

RUN mkdir -p $DATA_DIR

VOLUME $DATA_DIR

ENV JAVA_OPTS -d64 -Xmx4048m -Xms512m -Dorg.apache.catalina.security.SecurityListener.UMASK=0007 -server -Dramadda_home=$DATA_DIR -XX:PermSize=256m -XX:MaxPermSize=256m -Dfile.encoding=utf-8

ENV CATALINA_OPTS -Dorg.apache.jasper.runtime.BodyContentImpl.LIMIT_BUFFER=true

CMD ["catalina.sh", "run"]
