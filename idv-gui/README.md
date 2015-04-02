# dockerfile-idv README

This directory contains the `Dockerfile` used to build a docker container which will run the IDV embedded in an `x11vnc` virtual framebuffer.

## Building the Docker Image

    Building the docker image requires a file, IDV5.tar.bz2.   This file is simply a bzip2 compressed tarfile containing the contents of a linux IDV install.  

To build the docker image, you would run the following command from this directory:

> $ docker build -t idv .

## Running the Docker Image

In order to run this docker image, we need to expose a port which will be mapped to `5900` on the container.  Note that the `5900` port is already exposed in the `Dockerfile`.  We need to specify the port mapping when invoking `docker run`.  

Invoke `docker run` in one of the following fashions:

Invocation | Note
----|----
$ docker run -p 5900 | Map 5900 to a random port on the host.
$ docker run -p 5900:5901 | Map 5900 on container to 5901 on host.

You can see how ports are mapped via either `docker ps` or `docker port`, e.g.

> $ docker ps

or 

> $ docker port [container name]
