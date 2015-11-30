# IDV Webcams #

This is a docker project that ultimately runs a tcl script, that goes around the
web scraping images for the [Unidata Integrated Data Viewer](http://www.unidata.ucar.edu/software/idv/) (IDV). (See the Display --> Special --> Webcam Display menu in the IDV.) The `getImages.tcl` script is a constantly running script (do not put it in cron or you will inadvertently launch a denial of service attack) that fetches images every fifteen minutes. The images are scoured off after a couple of days.

The URL webcam database is in the `defineImages.tcl` file. This file needs to be updated on a regular basis as webcam URLs go quickly out-of-date.

Before running, please edit the `docker-compose.yml` file and decide where you want the images to live on the base machine. See the `CHANGEME!` environment variable. Note that the same `docker-compose.yml` references an nginx web server image that will serve out the images.

To access your new IDV webcam server, please locate the `.rbi` in your `~/.unidata` folder for your IDV instalation and insert lines that look something like this:

    ```
    <!-- Defines the image set xml -->
    <resources name="idv.resource.imagesets" loadmore="true">
        <resource location="http://idv-webcams.cloudapp.net/index.xml"/>
    </resources>
    ```

Note, you will have to change the name of the webcam URL (the `resource location` element) to wherever on the Internet your Docker image lives. You will also have to open port 80 to let web traffic for the IDV to grab images. Finally, apart from the IDV, it is always fun to examine the latest images at:

[http://idv-webcams.cloudapp.net/latest.html](http://idv-webcams.cloudapp.net/latest.html)
