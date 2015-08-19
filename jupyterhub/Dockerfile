FROM jupyter/jupyterhub

MAINTAINER Ryan May <rmay@ucar.edu>

# Install oauthenticator and dockerspawner from git
RUN pip3 install git+git://github.com/jupyter/oauthenticator.git
RUN pip3 install git+git://github.com/jupyter/dockerspawner.git

# Create oauthenticator directory and put necessary files in it
RUN mkdir /srv/oauthenticator
WORKDIR /srv/oauthenticator
ENV OAUTHENTICATOR_DIR /srv/oauthenticator
RUN chmod 700 /srv/oauthenticator
ADD nesteddockerspawner.py /srv/jupyterhub/nesteddockerspawner.py

# ssl cert/key mounted from outside container
VOLUME /srv/oauthenticator/ssl
