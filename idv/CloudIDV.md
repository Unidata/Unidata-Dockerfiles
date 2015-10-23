# CloudIDV

This docker image contains an instance of the Unidata Integrated Data Viewer (IDV) running within a virtual X11 environment.  It is accessed via a web browser, once it is up and running.

#### Running the CloudIDV Docker Image

CloudIDV is started in the following fashion:

    $ docker run -p 6080:6080 -it unidata/cloudidv

Alternatively, if you wish to run multiple sessions, or leverage 

### Connecting to the CloudIDV Session

The CloudIDV uses a web browser to connect.  You will use the IP address of the docker server, and port 6080.  On linux, the IP address will typically be **127.0.0.1**.  On Windows or OSX, you will use the `docker-machine` command to determine the IP address.  Assuming you are using the `default` docker machine, you would discover the IP as follows:

    $ docker-machine ip default

At this point, you would enter the following in your web browser address bar:

* `http://<IP>:<port>`

This will connect you to your CloudIDV session.

# Advanced Options

The following advanced options are available when running the cloudidv docker image.  

* SIZEH: Screen Height, default 1024
* SIZEW: Screen Width, default 768
* CDEPTH: Color Depth, default 24

You would use these parameters as follows:

    $ docker run -p 6080:6080 -e SIZEH=1440 -e SIZEW=900 -e CDEPTH=8 -it unidata/cloudidv

You would, of course, replace the values with your desired dimensions.
