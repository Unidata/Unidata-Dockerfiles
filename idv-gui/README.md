# dockerfile-idv README

This directory contains the `Dockerfile` used to build a docker container which will run the IDV embedded in an `x11vnc` virtual framebuffer.

## Building the Docker Image

    Building the docker image requires a file, IDV5.tar.bz2.   This file is simply a bzip2 compressed tarfile containing the contents of a linux IDV install.  

To build the docker image, you would run the following command from this directory:

> $ docker build -t idv-gui .

## Running the Docker Image

The docker image may be run one of two ways. Either from the command line, or via the `run_idv.sh` utility script.  The latter is easier, but the former is more configurable.

### Script

    $ ./run_idv.sh unidata/idv-gui
    
### Command Line

    $ docker run -p 5901:5901 -it unidata/idv-gui ./startidv.sh
    
Note that you can modify the X11 screen dimensions using the following parameters:

Parameter | Default | Note
----|---- | ----
SIZEH | 1024 | Screen Height
SIZEW | 768 | Screen Width
CDEPTH | 24  | Color Depth

You would use these parameters as follows:

    $ docker run -p 5901:5901 -e SIZEH=1440 -e SIZEW=900 -e CDEPTH=8 -it unidata/idv-gui ./startidv.sh
    
You would, of course, replace the values with your desired dimensions.

### Note: Exposing ports

In order to run this docker image, we need to expose a port which will be mapped to `5901` on the container.  Note that the `5901 port is already exposed in the `Dockerfile`.  We need to specify the port mapping when invoking `docker run`.  

Invoke `docker run` in one of the following fashions:

Invocation | Note
----|----
$ docker run -p 5901 | Map 5900 to a random port on the host.
$ docker run -p 5901:5901 | Map 5900 on container to 5901 on host.

You can see how ports are mapped via either `docker ps` or `docker port`, e.g.

> $ docker ps

or 

> $ docker port [container name]
