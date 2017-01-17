- [Introduction](#orgheadline1)
- [Obtain Jetstream Resources](#orgheadline2)
- [Configure Jetstream to Run Unidata Docker Containers](#orgheadline32)
  - [Clone the Unidata-Dockerfiles Repository](#orgheadline3)
  - [Build and Start the Jetstream API Docker Container](#orgheadline7)
    - [Create ssh Keys](#orgheadline4)
    - [Download openrc.sh](#orgheadline5)
    - [Build the openstack-client Container](#orgheadline6)
  - [Set Up Jetstream API to Create VMs](#orgheadline8)
  - [Working with Jetstream API to Create VMs](#orgheadline13)
    - [IP Numbers](#orgheadline9)
    - [Boot VM](#orgheadline10)
    - [Create and Attach Data Volumes](#orgheadline11)
    - [ssh Into New VM](#orgheadline12)
  - [Set up VM to Run LDM, TDS, RAMADDA, ADDE](#orgheadline30)
    - [VM Maintenance and Install git](#orgheadline14)
    - [Clone Unidata-Dockerfiles](#orgheadline15)
    - [Run the VM Set Up Script and Reboot](#orgheadline16)
    - [Check Docker Installation](#orgheadline17)
    - [Mount Data Volumes](#orgheadline18)
    - [Clone Unidata-Dockerfiles and TdsConfig Repositories](#orgheadline19)
    - [Create Log Directories](#orgheadline20)
    - [Configure the LDM](#orgheadline22)
    - [Configure the TDS](#orgheadline24)
    - [Configure RAMADDA](#orgheadline25)
    - [Configure McIDAS ADDE](#orgheadline26)
    - [Create a Self-Signed Certificates](#orgheadline27)
    - [TDS Host and TDM User](#orgheadline28)
    - [Configure TDM](#orgheadline29)
  - [chown for Good Measure](#orgheadline31)
- [Start Everything](#orgheadline34)
  - [Bootstrapping](#orgheadline33)
- [References](#orgheadline35)
- [Acknowledgments](#orgheadline36)


# Introduction<a id="orgheadline1"></a>

This guide is a companion document [(available in HTML, Markdown, text, PDF)](https://github.com/Unidata/Unidata-Dockerfiles/tree/master/jetstream/readme) to a 2017 American Meteorological Society oral presentation, [*Geoscientific Data Distribution in the XSEDE Jetstream Cloud*](https://ams.confex.com/ams/97Annual/webprogram/Paper315508.html). It describes how to configure the [LDM](http://www.unidata.ucar.edu/software/ldm/), [TDS](http://www.unidata.ucar.edu/software/thredds/current/tds/), [RAMADDA](http://sourceforge.net/projects/ramadda/), and [McIDAS ADDE](https://www.ssec.wisc.edu/mcidas/) on [XSEDE Jetstream VMs](https://www.xsede.org/jump-on-jetstream). It assumes you have access to Jetstream resources though these instructions should be fairly similar on other cloud providers (e.g., Amazon). These instructions also require familiarity with Unix, Docker, and Unidata technology in general. We will also be making use of the [Jetstream API](https://iujetstream.atlassian.net/wiki/display/JWT/Using+the+Jetstream+API). Obtain permission from the XSEDE Jetstream team to use Jetstream API. You must be comfortable entering commands at the Unix command line. We will be using Docker images available at the [Unidata Github account](https://github.com/Unidata) in addition to a configuration specifically planned for an [AMS 2017 demonstration](http://jetstream.unidata.ucar.edu).

# Obtain Jetstream Resources<a id="orgheadline2"></a>

[Apply for cloud resource allocations on Jetstream](https://www.xsede.org/jump-on-jetstream).

# Configure Jetstream to Run Unidata Docker Containers<a id="orgheadline32"></a>

## Clone the Unidata-Dockerfiles Repository<a id="orgheadline3"></a>

We will be making heavy use of the `Unidata/Unidata-Dockerfiles` git repository. [Install git](https://www.git-scm.com/book/en/v2/Getting-Started-Installing-Git) and clone that repository first:

```sh
git clone https://github.com/Unidata/Unidata-Dockerfiles
```

## Build and Start the Jetstream API Docker Container<a id="orgheadline7"></a>

We will be using the Jetstream API directly and via convenience scripts. Install Docker (e.g., [docker-machine](https://docs.docker.com/machine/)) on your local computing environment because we will be interacting with the Jetstream API in a Docker container.

```sh
cd Unidata-Dockerfiles/jetstream/openstack
```

### Create ssh Keys<a id="orgheadline4"></a>

Create an `.ssh` directory for your ssh keys:

```sh
mkdir -p .ssh && ssh-keygen -b 2048 -t rsa -f .ssh/id_rsa -P ""
```

### Download openrc.sh<a id="orgheadline5"></a>

Download the `openrc.sh` file into the `Unidata-Dockerfiles/jetstream/openstack` directory [according to the Jetstream API instructions](https://iujetstream.atlassian.net/wiki/display/JWT/Setting+up+openrc.sh). In the Jetstream Dashboard, navigate to `Access & Security`, `API Access` to download `openrc.sh`.

Edit the `openrc.sh` file and the supply the TACC resource `OS_PASSWORD`:

```sh
export OS_PASSWORD="changeme!"
```

Comment out

```sh
# echo "Please enter your OpenStack Password: "
# read -sr OS_PASSWORD_INPUT
```

### Build the openstack-client Container<a id="orgheadline6"></a>

Build the `openstack-client` container, here done via `docker-machine`.

```sh
docker-machine create --driver virtualbox openstack
eval "$(docker-machine env openstack)"
docker build -t openstack-client .
```

## Set Up Jetstream API to Create VMs<a id="orgheadline8"></a>

Start the `openstack-client` container with

```sh
sh os.sh
```

You should be inside the container which has been configured to run openstack `nova` and `neutron` commands. [Go though the following Jetstream API sections](https://iujetstream.atlassian.net/wiki/display/JWT/OpenStack+command+line):

-   Create security group
-   Upload SSH key
-   Setup the network

At this point, you should be able to run `glance image-list` which should yield something like:

| ID                                   | Name                               |
|------------------------------------ |---------------------------------- |
| fd4bf587-39e6-4640-b459-96471c9edb5c | AutoDock Vina Launch at Boot       |
| 02217ab0-3ee0-444e-b16e-8fbdae4ed33f | AutoDock Vina with ChemBridge Data |
| b40b2ef5-23e9-4305-8372-35e891e55fc5 | BioLinux 8                         |

If not, check your setup.

## Working with Jetstream API to Create VMs<a id="orgheadline13"></a>

### IP Numbers<a id="orgheadline9"></a>

We are ready to fire up VMs. First create an IP number which we will be using shortly:

```sh
nova floating-ip-create public
nova floating-ip-list
```

or you can just `nova floating-ip-list` if you have IP numbers left around from previous VMs.

### Boot VM<a id="orgheadline10"></a>

Now you can boot up a VM with something like the following command:

```sh
boot.sh -n unicloud -s m1.medium -ip 149.165.157.137
```

The `boot.sh` command takes a VM name, size, and IP number created earlier. See `boot.sh -h` and `nova flavor-list` for more information.

### Create and Attach Data Volumes<a id="orgheadline11"></a>

Also, create and attach `/data` and `/repository` volumes which we will be using shortly via the openstack API:

```:eval
cinder create 750 --display-name data
cinder create 100 --display-name repository

cinder list && nova list

nova volume-attach <vm-uid-number> <volume-uid-number> auto
nova volume-attach <vm-uid-number> <volume-uid-number> auto
```

### ssh Into New VM<a id="orgheadline12"></a>

`ssh` into that newly minted VM:

```:eval
ssh ubuntu@149.165.157.137
```

If you are having trouble logging in, you may try to delete the `~/.ssh/known_hosts` file. If you still have trouble, try `nova stop <vm-uid-number>` followed by `nova stop <vm-uid-number>`.

## Set up VM to Run LDM, TDS, RAMADDA, ADDE<a id="orgheadline30"></a>

### VM Maintenance and Install git<a id="orgheadline14"></a>

As `root` (`sudo su -`), update, upgrade and install `git`:

```sh
apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade && \
    apt-get -y install git ntp
```

Create a `git` directory for the `Unidata-Dockerfiles` project.

```sh
mkdir -p ~/git
```

### Clone Unidata-Dockerfiles<a id="orgheadline15"></a>

Clone the the `Unidata-Dockerfiles` project.

```:eval
git clone https://github.com/Unidata/Unidata-Dockerfiles ~/git/Unidata-Dockerfiles
```

### Run the VM Set Up Script and Reboot<a id="orgheadline16"></a>

Install `Docker` and `docker-compose` and get the `ubuntu` user set up to run docker.

```sh
bash ~/git/Unidata-Dockerfiles/docker-vm-setup/ubuntu/setup-ubuntu.sh -u ubuntu \
     -dc 1.8.1
```

Reboot

```:eval
reboot now
```

### Check Docker Installation<a id="orgheadline17"></a>

Log back in to the VM as user `ubuntu`. Test `docker` with

```sh
docker run hello-world
```

If docker gives an error

    docker: An error occurred trying to connect: Post http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/create: read unix @->/var/run/docker.sock: read: connection reset by peer.
    See 'docker run --help'.

Try as `root`

```sh
service docker stop
rm -rf /var/lib/docker/aufs #always think hard before rm -rf
service docker start
```

If the `hello-world` container runs smoothly, continue.

### Mount Data Volumes<a id="orgheadline18"></a>

As `root`, run some convenience scripts to mount the data volumes for data being delivered via the LDM (`/data`) and RAMADDA (`/repository`).

```sh
bash ~/git/Unidata-Dockerfiles/jetstream/openstack/mount.sh -m /dev/sdb \
     -d /data
bash ~/git/Unidata-Dockerfiles/jetstream/openstack/mount.sh -m /dev/sdc \
     -d /repository

# ensure disks reappear on startup
echo /dev/sdb   /data   ext4  rw      0 0 | tee --append /etc/fstab > /dev/null
echo /dev/sdc   /repository   ext4  rw      0 0 | tee --append /etc/fstab > /dev/null
```

### Clone Unidata-Dockerfiles and TdsConfig Repositories<a id="orgheadline19"></a>

We will again be cloning the `Unidata-Dockerfiles` repository, this time as user `ubuntu`.

```sh
mkdir -p ~/git
git clone https://github.com/Unidata/Unidata-Dockerfiles \
    ~/git/Unidata-Dockerfiles
git clone https://github.com/Unidata/TdsConfig ~/git/TdsConfig
```

### Create Log Directories<a id="orgheadline20"></a>

Create all log directories

```sh
mkdir -p ~/logs/ldm/ ~/logs/ramadda-tomcat/ ~/logs/ramadda/ ~/logs/tds-tomcat/ \
      ~/logs/tds/ ~/logs/traefik/ ~/logs/tdm/
```

### Configure the LDM<a id="orgheadline22"></a>

Grab the ldm `etc` directory

```sh
mkdir -p ~/etc
cp -r ~/git/Unidata-Dockerfiles/jetstream/etc/* ~/etc/
```

In the `~/etc` you will find the usual LDM configuration files (e.g., `ldmd.conf`, `registry.xml`). Configure them to your liking.

1.  NTP

    As root, you also want to ensure the network time protocol configuration file accesses `timeserver.unidata.ucar.edu`.
    
    ```sh
    sed -i \
        s/server\ 0.ubuntu.pool.ntp.org/server\ timeserver.unidata.ucar.edu\\nserver\ 0.ubuntu.pool.ntp.org/g \
        /etc/ntp.conf
    ```

### Configure the TDS<a id="orgheadline24"></a>

In the `ldmd.conf` file we copied just a moment ago, there is a reference to a `pqact` file; `etc/TDS/pqact.forecastModels`. We need to ensure that file exists by doing the following instructions. Specifically, explode `~/git/TdsConfig/idd/config.zip` into `~/tdsconfig` and `cp -r` the `pqacts` directory into `~/etc/TDS`. **Note** do NOT use soft links. Docker does not like them. Be sure to edit `~/tdsconfig/threddsConfig.xml` for contact information in the `serverInformation` element.

```sh
mkdir -p ~/tdsconfig/ ~/etc/TDS
cp ~/git/TdsConfig/idd/config.zip ~/tdsconfig/
unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
cp -r ~/tdsconfig/pqacts/* ~/etc/TDS
```

1.  Edit ldmfile.sh

    Examine the `etc/TDS/util/ldmfile.sh` file. As the top of this file indicates, you must change the `logfile` to suit your needs. Change the
    
        logfile=logs/ldm-mcidas.log
    
    line to
    
        logfile=var/logs/ldm-mcidas.log
    
    This will ensure `ldmfile.sh` can properly invoked from the `pqact` files.
    
    We can achieve this change with a bit of `sed`:
    
    ```sh
    # in place change of logs dir w/ sed
    
    sed -i s/logs\\/ldm-mcidas.log/var\\/logs\\/ldm-mcidas\\.log/g \
        ~/etc/TDS/util/ldmfile.sh
    ```
    
    Also ensure that `ldmfile.sh` is executable.
    
    ```sh
    chmod +x ~/etc/TDS/util/ldmfile.sh
    ```

### Configure RAMADDA<a id="orgheadline25"></a>

When you start RAMADDA for the very first time, you must have a `password.properties` file in the RAMADDA home directory which is `/repository/`. See [RAMADDA documentation](http://ramadda.org//repository/userguide/toc.html) for more details on setting up RAMADDA. Here is a `pw.properties` file to get you going. Change password below to something more secure!

```sh
# Create RAMADDA default password

echo ramadda.install.password=changeme! | tee --append \
  /repository/pw.properties > /dev/null
```

### Configure McIDAS ADDE<a id="orgheadline26"></a>

```sh
cp ~/git/Unidata-Dockerfiles/jetstream/mcidas/pqact.conf_mcidasA ~/etc
mkdir -p ~/mcidas/upcworkdata/ ~/mcidas/decoders/ ~/mcidas/util/
cp ~/git/Unidata-Dockerfiles/mcidas/RESOLV.SRV ~/mcidas/upcworkdata/
```

### Create a Self-Signed Certificates<a id="orgheadline27"></a>

In the `~/git/Unidata-Dockerfiles/jetstream/files/` directory, generate a self-signed certificate with `openssl` (or better yet, obtain a real certificate from a certificate authority).

```sh
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj \
  "/C=US/ST=Colorado/L=Boulder/O=Unidata/CN=tomcat.example.com" \
  -keyout ~/git/Unidata-Dockerfiles/jetstream/files/ssl.key \
  -out ~/git/Unidata-Dockerfiles/jetstream/files/ssl.crt
```

### TDS Host and TDM User<a id="orgheadline28"></a>

Ensure the `TDS_HOST` URL (with a publicly accessible IP number of the docker host or DNS name) is correct in `/git/Unidata-Dockerfiles/jetstream/docker-compose.yml`.

In the same `docker-compose.yml` file, ensure the `TDM_PW` corresponds to the SHA digested password of the `tdm` user `/git/Unidata-Dockerfiles/jetstream/files/tomcat-users.xml`

```:eval
docker run tomcat  /usr/local/tomcat/bin/digest.sh -a "SHA" mysupersecretpassword
```

### Configure TDM<a id="orgheadline29"></a>

[TDM logging will not be configurable until TDS 5.0](https://github.com/Unidata/thredds-docker#capturing-tdm-log-files-outside-the-container). Until then:

```sh
curl -SL  \
     https://artifacts.unidata.ucar.edu/content/repositories/unidata-releases/edu/ucar/tdmFat/4.6.8/tdmFat-4.6.8.jar \
     -o ~/logs/tdm/tdm.jar
curl -SL https://raw.githubusercontent.com/Unidata/thredds-docker/master/tdm/tdm.sh \
     -o ~/logs/tdm/tdm.sh
chmod +x  ~/logs/tdm/tdm.sh
```

## chown for Good Measure<a id="orgheadline31"></a>

As `root` ensure that permissions are as they should be:

```sh
chown -R ubuntu:docker /data /repository ~ubuntu
```

# Start Everything<a id="orgheadline34"></a>

Fire up the whole kit and caboodle with `docker-compose.yml` which will start:

-   LDM
-   [Traefik](https://traefik.io/), a reverse proxy that will channel ramadda and tds http request to the right container
-   NGINX web server
-   RAMADDA
-   THREDDS
-   TDM
-   McIDAS ADDE

As user `ubuntu`:

```sh
docker-compose -f ~/git/Unidata-Dockerfiles/jetstream/docker-compose.yml up -d
```

## Bootstrapping<a id="orgheadline33"></a>

The problem at this point is that it will take a little while for the LDM to fill the `/data` directory up with data. I don't believe the TDS/TDM can "see" directories created after start up. Therefore, you may have to bootstrap this set up a few times as the `/data` directory fills up with:

```sh
cd ~/git/Unidata-Dockerfiles/jetstream/
docker-compose stop && docker-compose up -d
```

# References<a id="orgheadline35"></a>

Stewart, C.A., Cockerill, T.M., Foster, I., Hancock, D., Merchant, N., Skidmore, E., Stanzione, D., Taylor, J., Tuecke, S., Turner, G., Vaughn, M., and Gaffney, N.I., Jetstream: a self-provisioned, scalable science and engineering cloud environment. 2015, In Proceedings of the 2015 XSEDE Conference: Scientific Advancements Enabled by Enhanced Cyberinfrastructure. St. Louis, Missouri. ACM: 2792774. p. 1-8. <http://dx.doi.org/10.1145/2792745.2792774>

John Towns, Timothy Cockerill, Maytal Dahan, Ian Foster, Kelly Gaither, Andrew Grimshaw, Victor Hazlewood, Scott Lathrop, Dave Lifka, Gregory D. Peterson, Ralph Roskies, J. Ray Scott, Nancy Wilkins-Diehr, "XSEDE: Accelerating Scientific Discovery", Computing in Science & Engineering, vol.16, no. 5, pp. 62-74, Sept.-Oct. 2014, <10.1109/MCSE.2014.80>

# Acknowledgments<a id="orgheadline36"></a>

We thank Jeremy Fischer, Marlon Pierce, Suresh Marru, George Wm Turner, Brian Beck, Craig Alan Stewart, Victor Hazlewood and Peg Lindenlaub for their assistance with this effort, which was made possible through the XSEDE Extended Collaborative Support Service (ECSS) program.
