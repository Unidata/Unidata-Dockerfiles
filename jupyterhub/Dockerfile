FROM unidata/ubuntu-dev

MAINTAINER Ryan May <rmay@ucar.edu>
RUN apt-get install -y -q python3 python3-pip sqlite3 pandoc nodejs nodejs-legacy npm && apt-get clean

# install js dependencies
RUN npm install -g configurable-http-proxy

RUN pip3 install --upgrade setuptools pip

# Install oauthenticator and dockerspawner from git
RUN pip3 install git+git://github.com/jupyter/notebook.git
RUN pip3 install git+git://github.com/jupyter/jupyterhub.git
RUN pip3 install git+git://github.com/jupyter/oauthenticator.git
RUN pip3 install git+git://github.com/jupyter/dockerspawner.git

# Jupyterhub configs
ADD jupyterhub_config.py nesteddockerspawner.py /srv/jupyterhub/

# Create oauthenticator directory and put necessary files in it
ENV OAUTHENTICATOR_DIR /srv/oauthenticator/
RUN mkdir -p /srv/oauthenticator && chmod 700 /srv/oauthenticator

VOLUME /jpydb

WORKDIR /srv/jupyterhub
EXPOSE 8000
ENTRYPOINT ["jupyterhub", "-f", "/srv/jupyterhub/jupyterhub_config.py"]
