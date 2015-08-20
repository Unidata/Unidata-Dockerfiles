# Dockerfile for running a single user jupyter server
FROM continuumio/miniconda3

MAINTAINER Ryan May <rmay@ucar.edu>

# Install git
RUN apt-get -y install git

# fetch juptyerhub-singleuser entrypoint
ADD https://raw.githubusercontent.com/jupyter/jupyterhub/master/jupyterhub/singleuser.py /usr/local/bin/jupyterhub-singleuser
RUN chmod 755 /usr/local/bin/jupyterhub-singleuser
ADD singleuser.sh /srv/singleuser/singleuser.sh
ADD setup_kernel.sh /srv/singleuser/setup_kernel.sh
EXPOSE 8888

# Update conda and add channels
RUN conda update --yes --quiet conda
RUN conda config --add channels https://conda.binstar.org/scitools
RUN conda config --add channels https://conda.binstar.org/Unidata

# Create Python 3 environment
RUN conda create -n py3 --yes --quiet python=3 ipython-notebook numpy netcdf4 \
 matplotlib cartopy OWSLib siphon MetPy xray networkx
RUN bash /srv/singleuser/setup_kernel.sh py3

# Create Python 2 environment
RUN conda create -n py2 --yes --quiet python=2 ipython-notebook numpy netcdf4 \
  matplotlib cartopy OWSLib siphon MetPy xray networkx
RUN bash /srv/singleuser/setup_kernel.sh py2

# jupyter is our user
RUN useradd -m -s /bin/bash jupyter

USER jupyter
ENV HOME /home/jupyter
ENV SHELL /bin/bash
ENV USER jupyter

WORKDIR /home/jupyter/
VOLUME /home/jupyter/work

# Add unidata workshop notebooks
RUN git clone --depth=1 http://github.com/unidata/unidata-python-workshop

CMD ["bash", "/srv/singleuser/singleuser.sh"]
