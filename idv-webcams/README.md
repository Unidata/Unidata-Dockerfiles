- [Running IDV Webcams in the Cloud](#running-idv-webcams-in-the-cloud)
- [Routine Maintenance](#routine-maintenance)
- [`git clone` Repositories](#`git-clone`-repositories)
- [Add `ubuntu` User to `docker` Group and Restart Docker](#add-`ubuntu`-user-to-`docker`-group-and-restart-docker)
- [Install `docker-compose` on VM](#install-`docker-compose`-on-vm)
- [Create `www` directory](#create-`www`-directory)
- [Edit `docker-compose.yml`](#edit-`docker-compose.yml`)
- [`chown` for Good Measure](#`chown`-for-good-measure)
- [Logout/Restart/Login](#logout/restart/login)
- [Run](#run)
- [Access Webcams in the IDV](#access-webcams-in-the-idv)


# Running IDV Webcams in the Cloud<a id="orgheadline1"></a>

This is a docker project that ultimately runs a `tcl` script, that goes around the
web scraping images for the [Unidata Integrated Data Viewer](http://www.unidata.ucar.edu/software/idv) (IDV). (See the Display &#x2013;> Special &#x2013;> Webcam Display menu in the IDV.) The `getImages.tcl` script is a constantly running script (do not put it in `cron` or you will inadvertently launch a denial of service attack) that fetches images every fifteen minutes. The images are scoured off after a couple of days.

The URL webcam database is in the `defineImages.tcl` file. This file needs to be updated on a regular basis as webcam URLs go quickly out-of-date.

Follow the instructions below to run this project on a cloud service.

# Routine Maintenance<a id="orgheadline2"></a>

`ssh` into docker host first.

```sh
docker-machine ssh idv-webcams
```

Do some routine maintenance.

```sh
# update and install packages
sudo apt-get -qq update
sudo apt-get -qq upgrade
```

# `git clone` Repositories<a id="orgheadline3"></a>

Let's clone those repositories by creating `~/git` directory where our repositories will live and issuing some `git` commands.

```sh
# Get the git repositories we will want to work with
mkdir -p /home/ubuntu/git
git clone https://github.com/Unidata/Unidata-Dockerfiles \
    /home/ubuntu/git/Unidata-Dockerfiles
```

# Add `ubuntu` User to `docker` Group and Restart Docker<a id="orgheadline4"></a>

```sh
# Add ubuntu to docker group
sudo usermod -G docker ubuntu

# Restart docker service
sudo service docker restart
```

# Install `docker-compose` on VM<a id="orgheadline5"></a>

`docker-compose` is a tool for defining and running multi-container Docker applications. In our case, we will be running the LDM, TDS, TDM (THREDDS Data Manager) and RAMADDA so `docker-compose` is perfect for this scenario. Install `docker-compose` on the Azure Docker host.

You may have to update version (currently at `1.5.2`).

```sh
  # Get docker-compose
  curl -L \
  https://github.com/docker/compose/releases/download/1.5.2/\
docker-compose-`uname -s`-`uname -m` > docker-compose
  sudo mv docker-compose /usr/local/bin/
  sudo chmod +x /usr/local/bin/docker-compose
```

# Create `www` directory<a id="orgheadline6"></a>

```sh
# Create www directory
mkdir -p ~/www
```

# Edit `docker-compose.yml`<a id="orgheadline7"></a>

Before running, please edit the `docker-compose.yml` file and decide where you want the images to live on the base machine. See the `CHANGEME!` environment variable. Note that the same `docker-compose.yml` references an `nginx` web server image that will serve out the images.

# `chown` for Good Measure<a id="orgheadline8"></a>

As we are approaching completion, let's ensure all files in `/home/ubuntu` are owned by the `ubuntu` user in the `docker` group.

```sh
sudo chown -R ubuntu:docker /home/ubuntu
```

# Logout/Restart/Login<a id="orgheadline9"></a>

Best to get a clean start.

```sh
exit
docker-machine restart idv-webcams
docker-machine ssh idv-webcams
```

# Run<a id="orgheadline10"></a>

```sh
# Docker pull all relavant images
docker pull unidata/idv-webcams:latest
docker pull nginx
```

From `~/git/Unidata-Dockerfiles/idv-webcams`

```sh
docker-compose run -d idv-webcams
docker-compose run -d  --service-ports nginx
```

# Access Webcams in the IDV<a id="orgheadline11"></a>

To access your new IDV webcam server, please locate the `.rbi` in your `~/.unidata` folder for your IDV installation and insert lines that look something like this:

    <!-- Defines the image set xml -->
    <resources name="idv.resource.imagesets" loadmore="true">
        <resource location="http://idv-webcams.cloudapp.net/index.xml"/>
    </resources>

Note, you will have to change the name of the webcam URL (the `resource location` element) to wherever on the Internet your Docker image lives. You will also have to open port 80 to let web traffic for the IDV to grab images. Finally, apart from the IDV, it is always fun to examine the latest images at:

<http://idv-webcams.cloudapp.net/latest.html>
