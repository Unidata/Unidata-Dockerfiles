# Dockerfile for running a single user jupyter server
FROM unidata/ubuntu-dev

MAINTAINER Ryan May <rmay@ucar.edu>

# fetch juptyerhub-singleuser entrypoint
ADD https://raw.githubusercontent.com/jupyter/jupyterhub/master/jupyterhub/singleuser.py /usr/local/bin/jupyterhub-singleuser
RUN chmod 755 /usr/local/bin/jupyterhub-singleuser
ADD singleuser.sh /srv/singleuser/

# jupyter is our user -- set uid/gid to match base data image
RUN groupadd -g 1001 jupyter && useradd -u 1001 -g jupyter -m -s /bin/bash -d /home/jupyter jupyter
USER jupyter
ENV HOME=/home/jupyter SHELL=/bin/bash USER=jupyter PATH=/home/jupyter/conda/bin:$PATH
WORKDIR $HOME

# Install conda
RUN curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh > conda.sh && \
  /bin/bash conda.sh -bfp $HOME/conda && rm conda.sh

# Update conda and add channels
RUN conda update --yes --quiet conda

# Add the environment files
ADD env-python3.yml env-python2.yml $HOME/

# Create Python 3 environment
RUN conda env create -f env-python3.yml
RUN conda/envs/py3/bin/ipython kernel install --user

# Create Python 2 environment
RUN conda env create -f env-python2.yml
RUN conda/envs/py2/bin/ipython kernel install --user

# Add config for notebook
ADD ipython_kernel_config.py /home/jupyter/.ipython/profile_default/
ADD custom /home/jupyter/.jupyter/custom
ADD nbconfig /home/jupyter/.jupyter/nbconfig

# Make sure all added files are owned appropriately
USER root
RUN chown -R jupyter:jupyter /home/jupyter/.ipython /home/jupyter/.jupyter
USER jupyter

# Get extensions
ADD install_extensions.sh ./
RUN bash ./install_extensions.sh

VOLUME /notebooks
WORKDIR /notebooks
EXPOSE 8888

ENTRYPOINT ["/bin/bash", "/srv/singleuser/singleuser.sh"]
