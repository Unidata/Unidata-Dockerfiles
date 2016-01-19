- [Introduction](#introduction)
  - [Demonstration Servers](#demonstration-servers)
- [Quick Start](#quick-start)
- [Long Form Instructions](#long-form-instructions)
- [Preliminary Setup on Azure](#preliminary-setup-on-azure)
  - [Install `docker-machine`](#install-`docker-machine`)
  - [<a id="orgtarget1"></a>Create a VM on Azure](#<a-id="orgtarget1"></a>create-a-vm-on-azure)
  - [Configure Unix Shell to Interact with New Azure VM](#configure-unix-shell-to-interact-with-new-azure-vm)
  - [Restart Azure VM](#restart-azure-vm)
  - [`ssh` into VM with `docker-machine`](#`ssh`-into-vm-with-`docker-machine`)
  - [Install Packages with `apt-get`](#install-packages-with-`apt-get`)
  - [<a id="orgtarget6"></a>Add `ubuntu` User to `docker` Group and Restart Docker](#<a-id="orgtarget6"></a>add-`ubuntu`-user-to-`docker`-group-and-restart-docker)
  - [Install `docker-compose` on VM](#install-`docker-compose`-on-vm)
- [LDM and TDS Configuration](#ldm-and-tds-configuration)
  - [Background](#background)
    - [`Unidata-Dockerfiles` Repository](#`unidata-dockerfiles`-repository)
    - [`TDSConfig` Repository](#`tdsconfig`-repository)
  - [`git clone` Repositories](#`git-clone`-repositories)
  - [Configuring the LDM](#configuring-the-ldm)
    - [LDM Directories on Docker Host](#ldm-directories-on-docker-host)
    - [LDM Configuration Files](#ldm-configuration-files)
    - [Upstream Data Feed from Unidata or Elsewhere](#upstream-data-feed-from-unidata-or-elsewhere)
  - [Configuring the TDS](#configuring-the-tds)
    - [Edit TDS `catalog.xml` Files](#edit-tds-`catalog.xml`-files)
- [Setting up Data Volumes](#setting-up-data-volumes)
  - [Check Free Disk Space](#check-free-disk-space)
  - [Create `/data` Directory](#create-`/data`-directory)
- [Opening Ports](#opening-ports)
  - [More About the TDM](#more-about-the-tdm)
  - [Note about port ADDE 112](#note-about-port-adde-112)
- [Tomcat Logging for TDS and RAMADDA](#tomcat-logging-for-tds-and-ramadda)
- [Starting the LDM TDS RAMADDA TDM](#starting-the-ldm-tds-ramadda-tdm)
    - [RAMADDA Preconfiguration](#ramadda-preconfiguration)
    - [<a id="orgtarget3"></a>Final Edit to `docker-compose.yml`](#<a-id="orgtarget3"></a>final-edit-to-`docker-compose.yml`)
    - [`chown` for Good Measure](#`chown`-for-good-measure)
    - [Pull Down Images from the DockerHub Registry](#pull-down-images-from-the-dockerhub-registry)
    - [Start the LDM, TDS, TDM, RAMADDA](#start-the-ldm,-tds,-tdm,-ramadda)
- [<a id="orgtarget4"></a>Check What is Running](#<a-id="orgtarget4"></a>check-what-is-running)
  - [Docker Process Status](#docker-process-status)
  - [Checking Data Directory](#checking-data-directory)
  - [TDS and RAMADDA URLs](#tds-and-ramadda-urls)
  - [Viewing Data with the IDV](#viewing-data-with-the-idv)
    - [Access TDS with the IDV](#access-tds-with-the-idv)
    - [Access RAMADDAA with the IDV](#access-ramaddaa-with-the-idv)
- [Appendix](#appendix)
  - [Common Problems](#common-problems)
    - [<a id="orgtarget5"></a>Certificate Regeneration](#<a-id="orgtarget5"></a>certificate-regeneration)
    - [Size of VM is not Large Enough](#size-of-vm-is-not-large-enough)
    - [<a id="orgtarget8"></a>Where is my Data and the Finicky TDM](#<a-id="orgtarget8"></a>where-is-my-data-and-the-finicky-tdm)
    - [Cannot connect to the Docker daemon](#cannot-connect-to-the-docker-daemon)
  - [Asking for Help](#asking-for-help)
  - [Acknowledgments](#acknowledgments)


# Introduction<a id="orgheadline2"></a>

This guide is a companion document [(available in HTML, Markdown, text, PDF)](https://github.com/Unidata/Unidata-Dockerfiles/tree/master/ams2016/README) to a 2016 American Meteorological Society oral presentation, [*UniCloud: Docker Use at Unidata*](https://ams.confex.com/ams/96Annual/webprogram/Paper287336.html). It describes how to configure the [LDM](http://www.unidata.ucar.edu/software/ldm/), [TDS](http://www.unidata.ucar.edu/software/thredds/current/tds/), and [RAMADDA](http://sourceforge.net/projects/ramadda/) on a [Microsoft Azure VM](https://azure.microsoft.com). It assumes you have access to Azure resources though these instructions should be fairly similar on other cloud providers (e.g., Amazon). These instructions also require familiarity with Unix, Docker, and Unidata technology in general. You must have `sudo` privileges on the Azure host which will hopefully be available you. You must be comfortable entering commands at the Unix command line. We will be using Docker images defined at the [`Unidata-Dockerfiles` repository](https://github.com/Unidata/Unidata-Dockerfiles) in addition to a configuration specifically planned for an [AMS 2016 demonstrations  project](https://github.com/Unidata/Unidata-Dockerfiles/tree/master/ams2016). 

## Demonstration Servers<a id="orgheadline1"></a>

An example of having followed these instructions can be found with these [TDS](http://unidata-server.cloudapp.net/thredds/catalog.html) and [RAMADDA](http://unidata-server.cloudapp.net:8081/repository) demonstration servers running on the Azure cloud.

# Quick Start<a id="orgheadline3"></a>

In order to best understand this configuration process, it is recommended to read the complete contents of this document and follow the instructions starting in the next section. If there are problems you will be able to reason about the errors. However, if you are eager to get started, you can follow this quick start section.

-   `git clone https://github.com/Unidata/Unidata-Dockerfiles`
-   [Download and install](https://docs.docker.com/machine/install-machine/) `docker-machine`
-   Run the `Unidata-Dockerfiles/ams2016/unicloud-1.sh` script (this will take few minutes) to  [create the Docker host on Azure](#orgtarget1).

For example,

```sh
unicloud-1.sh \
  --azure-host <azure-host> \
  --azure-subscription-id "3.14" \
  --azure-subscription-cert \
  "/path/to/mycert.pem"
```

Now you are ready to do additional configuration on the new Docker host:

```sh
docker-machine \
  ssh <azure-host> "bash -s" < \
  Unidata-Dockerfiles/ams2016/unicloud-2.sh
```

Finally,

-   `ssh` into new Docker host with  `docker-machine ssh <azure-host>`
-   [Edit `registry.xml`](#orgtarget2) with the correct `hostname` element
-   [Edit `~git/Unidata-Dockerfiles/ams2016/docker-compose.yml`](#orgtarget3) with the correct `TDM_PW` and `TDS_HOST`.
-   Run `~/git/Unidata-Dockerfiles/ams2016/unicloud-3.sh`
-   [Check](#orgtarget4) your setup

# Long Form Instructions<a id="orgheadline4"></a>

If you are opting for the long form instructions instead of the quick start, begin here.

# Preliminary Setup on Azure<a id="orgheadline13"></a>

The VM we are about to create will be our **Docker Host** from where we will run Docker containers for the LDM, TDS, and RAMADDA.

## Install `docker-machine`<a id="orgheadline5"></a>

[Install `docker-machine`](https://docs.docker.com/machine/install-machine/)  on your local computer. `docker-machine` is a command line tool that gives users the ability to create Docker VMs on your local computer or on a cloud provider such as Azure.

## <a id="orgtarget1"></a>Create a VM on Azure<a id="orgheadline6"></a>

The following `docker-machine` command will create a Docker VM on Azure for running various Unidata Docker containers. **Replace the environment variables with your choices**. This command will take a few minutes to run (between 5 and 10 minutes). You will have to supply `azure-subscription-id` and `azure-subscription-cert` path. See the Azure `docker-machine` [instructions](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-docker-machine/), if you have questions about this process. Also set  [the size of the VM](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-size-specs/)  (e.g., `Small`, `ExtraLarge`) and supply the name of the Azure Docker host.

```org
# Create Azure VM via docker-machine
docker-machine \
  -D create \
  -d azure \
  --azure-subscription-id=$AZURE_ID \
  --azure-subscription-cert=$AZURE_CERT \
  --azure-size=$AZURE_SIZE $AZURE_HOST
```

## Configure Unix Shell to Interact with New Azure VM<a id="orgheadline7"></a>

Execute the following `eval` command on your local computer shell environment to ensure `docker` commands will be run with the newly created Docker host.

```org
# Ensure docker commands will be run with new host
eval "$(docker-machine env $AZURE_HOST)"
```

If you see an error message pertaining to `docker-machine regenerate-certs`, see the [Certificate Regeneration section of the Appendix](#orgtarget5).

## Restart Azure VM<a id="orgheadline8"></a>

Mysteriously, when you `ssh` (see next section) into the fresh VM, you are immediately told to restart it so let's preempt that message by doing that now.

```org
# immediately restart VM, according to Azure
docker-machine restart $AZURE_HOST
# Again, ensure docker commands will be run with new host
eval "$(docker-machine env $AZURE_HOST)"
```

## `ssh` into VM with `docker-machine`<a id="orgheadline9"></a>

```sh
docker-machine ssh $AZURE_HOST
```

## Install Packages with `apt-get`<a id="orgheadline10"></a>

At the very least, we will need `unzip` on the Azure Docker host. The Unix `tree` command can also be handy. `docker` is already installed on Azure by default.

```sh
# update and install packages
sudo apt-get -qq update
sudo apt-get -qq upgrade
sudo apt-get -qq install unzip tree
```

## <a id="orgtarget6"></a>Add `ubuntu` User to `docker` Group and Restart Docker<a id="orgheadline11"></a>

```sh
# Add ubuntu to docker group
sudo usermod -G docker ubuntu

# Restart docker service
sudo service docker restart
```

In Unix, when adding a user to a group, it is simply easiest to logout and log back in for this change to be recognized. Do that by exiting the VM and logging back in with `docker-machine ssh` command.

## Install `docker-compose` on VM<a id="orgheadline12"></a>

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

# LDM and TDS Configuration<a id="orgheadline29"></a>

## Background<a id="orgheadline16"></a>

We have done the preliminary legwork to tackle the next step in this process. We will now want to clone two repositories that will allow us to configure and start running the the LDM, TDS, and RAMADDA. In particular, we will be cloning:

-   [`github.com/Unidata/Unidata-Dockerfiles`](https://github.com/Unidata/Unidata-Dockerfiles)
-   [`github.com/Unidata/TdsConfig`](https://github.com/Unidata/TdsConfig)

### `Unidata-Dockerfiles` Repository<a id="orgheadline14"></a>

The `Unidata-Dockerfiles` repository contains a number of Dockerfiles that pertain to various Unidata technologies (e.g., the LDM) and also projects (e.g., ams2016). As a matter of background information, a `Dockerfile` is a text file that contains commands to build a Docker image containing, for example, a working LDM. These Docker images can subsequently be run by `docker` command line tools, or `docker-compose` commands that rely on a `docker-compose.yml` configuration file. A `docker-compose.yml` file is a text file that captures exactly how one or more containers run including directory mappings (from outside to within the container), port mappings (from outside to within the container), and other information.

### `TDSConfig` Repository<a id="orgheadline15"></a>

The `TDSConfig` repository is a project that captures THREDDS and LDM configuration files (e.g., `catalog.xml`, `pqact.conf`) for the TDS at <http://thredds.ucar.edu>. Specifically, these TDS and LDM configurations were meant to work in harmony with one another. We can re-use this configuration with some minor adjustments for running the TDS on the Azure cloud.

## `git clone` Repositories<a id="orgheadline17"></a>

With that background information out of the way, let's clone those repositories by creating `~/git` directory where our repositories will live and issuing some `git` commands.

```sh
# Get the git repositories we will want to work with
mkdir -p /home/ubuntu/git
git clone https://github.com/Unidata/Unidata-Dockerfiles \
    /home/ubuntu/git/Unidata-Dockerfiles
git clone https://github.com/Unidata/TdsConfig /home/ubuntu/git/TdsConfig
```

## Configuring the LDM<a id="orgheadline26"></a>

### LDM Directories on Docker Host<a id="orgheadline18"></a>

For anyone who has worked with the LDM, you may be familiar with the following directories:

-   `etc/`
-   `var/data`
-   `var/logs`
-   `var/queue`

The LDM `etc` directory is where you will find configuration files related to the LDM including `ldmd.conf`, `pqact` files, `registry.xml`, and  `scour.conf`. We will need the ability to easily observe and manipulate the files from **outside** the running LDM container. To that end, we need to find a home for `etc` on the Docker host. The same is true for the `var/data` and `var/logs` directories. Later, we will use Docker commands that have been written on your behalf to mount these directories from **outside** to **within** the container. The `var/queues` directory will remain inside the container.

```sh
# Create LDM directories
mkdir -p ~/var/logs 
mkdir -p ~/etc/TDS
```

`var/data` is a bit different in that it needs to be mounted on data volume on the Docker host. We will be handling that step further on.

### LDM Configuration Files<a id="orgheadline24"></a>

There is a generic set of LDM configuration files located here `~/git/Unidata-Dockerfiles/ldm/etc/`. However, we will just grab `netcheck.conf` which will remain unmodified.

```sh
# Copy various files for the LDM.
cp ~/git/Unidata-Dockerfiles/ldm/etc/netcheck.conf ~/etc
```

The rest of the LDM configuration files will come from our `ams2016` project directory. Also, remember that these files will be used **inside** the LDM container that we will set up shortly. We will now be working with these files:

-   `ldmd.conf`
-   `registry.xml`
-   `scour.conf`

1.  `ldmd.conf`

    ```sh
    cp ~/git/Unidata-Dockerfiles/ams2016/ldmd.conf ~/etc/
    ```
    
    This `ldmd.conf` has been setup for the AMS 2016 demonstration serving the following data feeds:
    
    -   [13km Rapid Refresh](http://rapidrefresh.noaa.gov/)
    -   [GFS One Degree](http://www.nco.ncep.noaa.gov/pmb/products/gfs/)
    -   [NESDIS GOES Satellite Data](http://www.nesdis.noaa.gov/imagery_data.html)
    -   Unidata NEXRAD Composites
    
      
    For your information, and for future reference, there is a `~/git/TdConfig/idd/pqacts/README.txt` file that may be helpful in writing a suitable `ldmd.conf` file.

2.  <a id="orgtarget2"></a> `registry.xml`

    ```sh
    cp ~/git/Unidata-Dockerfiles/ams2016/registry.xml ~/etc/
    ```
    
    This file has been set up for the AMS 2016 demonstration. Otherwise you will have to edit the `registry.xml` to ensure the `hostname` element is correct. For your own cloud VMs, and if you are part of the American academic community, work with `support-idd@unidata.ucar.edu` to devise a correct `hostname` element so that LDM statistics get properly reported. Here is an example `hostname` element:
    
        unidata-server.azure.unidata.ucar.edu

3.  `scour.conf`

    You need to scour data or else your disk will full up. The crontab entry that runs scour is in the [LDM Docker container](https://github.com/Unidata/Unidata-Dockerfiles/blob/master/ldm/crontab). Scouring is invoked once per day.
    
    ```sh
    cp ~/git/Unidata-Dockerfiles/ams2016/scour.conf ~/etc/
    ```

4.  `pqact.conf` and TDS configuration

    In the `ldmd.conf` file we copied just a moment ago, there is a reference to a `pqact` file; `etc/TDS/pqact.forecastModels`. We need to ensure that file exists by doing the following instructions. Specifically, explode `~/git/TdsConfig/idd/config.zip` into `~/tdsconfig` and `cp -r` the `pqacts` directory into `~/etc/TDS`. **Note** do NOT use soft links. Docker does not like them.
    
    ```sh
    # Set up LDM and TDS configuration
    mkdir -p ~/tdsconfig/
    cp ~/git/TdsConfig/idd/config.zip ~/tdsconfig/
    unzip ~/tdsconfig/config.zip -d ~/tdsconfig/
    cp -r ~/tdsconfig/pqacts/* ~/etc/TDS
    ```

5.  <a id="orgtarget7"></a>Edit `ldmfile.sh`

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

### Upstream Data Feed from Unidata or Elsewhere<a id="orgheadline25"></a>

The LDM operates on a push data model. You will have to find an institution who will agree to push you the data. If you are part of the American academic community please send a support email to `support-idd@unidata.ucar.edu` to discuss your LDM data requirements.

## Configuring the TDS<a id="orgheadline28"></a>

### Edit TDS `catalog.xml` Files<a id="orgheadline27"></a>

The `catalog.xml` files for TDS configuration are contained within the `~/tdsconfig` directory. Search for all files terminating in `.xml` in that directory. Edit the `xml` files for what data you wish to server. See the [TDS Documentation](http://www.unidata.ucar.edu/software/thredds/current/tds/catalog/index.html) for more information on editing these XML files.

Let's see **some** of what is available in the `~/tdsconfig` directory.

```sh
find ~/tdsconfig -name *.xml | awk 'BEGIN { FS = "/" } ; { print $NF }' | head
```

    forecastModels.xml
    radars.xml
    obsData.xml
    forecastProdsAndAna.xml
    satellite.xml
    CS039_L2_stations.xml
    CS039_stations.xml
    RadarNexradStations.xml
    RadarTerminalStations.xml
    RadarL2Stations.xml

For the purposes of the AMS demonstration, let's extract some catalog `xml` files that are consistent with the rest of this configuration:

```sh
# use catalog xml files that are consistent with our data holdings
cp -r ~/git/Unidata-Dockerfiles/ams2016/catalogs/* ~/tdsconfig
```

# Setting up Data Volumes<a id="orgheadline32"></a>

As alluded to earlier, we will have to set up data volumes so that the LDM can write data, and the TDS and RAMADDA can have access to that data. The `/mnt` has lots of space, but the storage is considered **ephemeral** so be careful! Azure makes no effort to backup data on `/mnt`. For the LDM this should not be too much of a problem because real time data is coming in and getting scoured continuously, but for <span class="underline">for any other application you may wish to be careful as there is the potential to lose data</span>. There is more information about this topic [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-how-to-attach-disk/).

## Check Free Disk Space<a id="orgheadline30"></a>

Let's first display the free disk space with the `df` command. 

```sh
df -H
```

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-right" />

<col  class="org-left" />

<col  class="org-right" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Filesystem</th>
<th scope="col" class="org-left">Size</th>
<th scope="col" class="org-right">Used</th>
<th scope="col" class="org-left">Avail</th>
<th scope="col" class="org-right">Use%</th>
<th scope="col" class="org-left">Mounted on</th>
<th scope="col" class="org-left">&#xa0;</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">udev</td>
<td class="org-left">7.4G</td>
<td class="org-right">0</td>
<td class="org-left">7.4G</td>
<td class="org-right">0%</td>
<td class="org-left">/dev</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">tmpfs</td>
<td class="org-left">1.5G</td>
<td class="org-right">27M</td>
<td class="org-left">1.5G</td>
<td class="org-right">2%</td>
<td class="org-left">/run</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">/dev/sda1</td>
<td class="org-left">31G</td>
<td class="org-right">6.6G</td>
<td class="org-left">24G</td>
<td class="org-right">22%</td>
<td class="org-left">/</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">tmpfs</td>
<td class="org-left">7.4G</td>
<td class="org-right">463k</td>
<td class="org-left">7.4G</td>
<td class="org-right">1%</td>
<td class="org-left">/dev/shm</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">tmpfs</td>
<td class="org-left">5.3M</td>
<td class="org-right">0</td>
<td class="org-left">5.3M</td>
<td class="org-right">0%</td>
<td class="org-left">/run/lock</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">tmpfs</td>
<td class="org-left">7.4G</td>
<td class="org-right">0</td>
<td class="org-left">7.4G</td>
<td class="org-right">0%</td>
<td class="org-left">/sys/fs/cgroup</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">none</td>
<td class="org-left">66k</td>
<td class="org-right">0</td>
<td class="org-left">66k</td>
<td class="org-right">0%</td>
<td class="org-left">/etc/network/interfaces.dynamic.d</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">/dev/sdb1</td>
<td class="org-left">640G</td>
<td class="org-right">187G</td>
<td class="org-left">421G</td>
<td class="org-right">31%</td>
<td class="org-left">/mnt</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">cgmfs</td>
<td class="org-left">103k</td>
<td class="org-right">0</td>
<td class="org-left">103k</td>
<td class="org-right">0%</td>
<td class="org-left">/run/cgmanager/fs</td>
<td class="org-left">&#xa0;</td>
</tr>


<tr>
<td class="org-left">tmpfs</td>
<td class="org-left">1.5G</td>
<td class="org-right">0</td>
<td class="org-left">1.5G</td>
<td class="org-right">0%</td>
<td class="org-left">/run/user/1000</td>
<td class="org-left">&#xa0;</td>
</tr>
</tbody>
</table>

## Create `/data` Directory<a id="orgheadline31"></a>

Create a `/data` directory where the LDM can write data soft link to the `/mnt` directory. Also, create a `/repository` directory where RAMADDA data will reside.

```sh
# Set up data directories
sudo ln -s /mnt /data
sudo mkdir /mnt/ldm/
sudo chown -R ubuntu:docker /data/ldm
sudo mkdir /home/ubuntu/repository/
sudo chown -R ubuntu:docker /home/ubuntu/repository
```

These directories will be used by the LDM, TDS, and RAMADDA docker containers when we mount directories from the Docker host into these containers.

# Opening Ports<a id="orgheadline35"></a>

[Ensure these ports are open](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-set-up-endpoints/) on the VM where these containers will run.

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Service</th>
<th scope="col" class="org-right">External Port</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">HTTP</td>
<td class="org-right">80</td>
</tr>


<tr>
<td class="org-left">TDS</td>
<td class="org-right">8080</td>
</tr>


<tr>
<td class="org-left">RAMADDA</td>
<td class="org-right">8081</td>
</tr>


<tr>
<td class="org-left">SSL TDM</td>
<td class="org-right">8443</td>
</tr>


<tr>
<td class="org-left">LDM</td>
<td class="org-right">388</td>
</tr>


<tr>
<td class="org-left">ADDE</td>
<td class="org-right">112</td>
</tr>
</tbody>
</table>

## More About the TDM<a id="orgheadline33"></a>

Note the TDM is an application that works in conjunction with the TDS. It creates indexes for GRIB data in the background, and notifies the TDS via port 8443 when data have been updated or changed. See [here](https://www.unidata.ucar.edu/software/thredds/current/tds/reference/collections/TDM.html) to learn more about the TDM. 

## Note about port ADDE 112<a id="orgheadline34"></a>

The ADDE port `112` is for future use since we have not dockerized ADDE, yet.

# Tomcat Logging for TDS and RAMADDA<a id="orgheadline36"></a>

It is advisable to mount Tomcat logging directories outside the container so that they can be managed for both the TDS and RAMADDA.

```sh
# Create Tomcat logging directories
mkdir -p ~/logs/ramadda-tomcat
mkdir -p ~/logs/tds-tomcat
```

Note there is also a logging directory in `~/tdsconfig/logs`. All these logging directories should be looked at periodically, not the least to ensure that `log` files are not filling up your system.

# Starting the LDM TDS RAMADDA TDM<a id="orgheadline42"></a>

### RAMADDA Preconfiguration<a id="orgheadline37"></a>

When you start RAMADDA for the very first time, you must have  a `password.properties` file in the RAMADDA home directory which is `/home/ubuntu/repository/`. See [RAMADDA documentation](http://ramadda.org//repository/userguide/toc.html) for more details on setting up RAMADDA. Here is a `pw.properties` file to get you going. Change password below to something more secure!

```sh
# Create RAMADDA default password
echo ramadda.install.password=changeme! > \
  /home/ubuntu/repository/pw.properties
```

### <a id="orgtarget3"></a>Final Edit to `docker-compose.yml`<a id="orgheadline38"></a>

When the TDM communicates to the TDS concerning changes in data it observes with data supplied by the LDM, it will communicate via the `tdm` tomcat user. Edit the `docker-compose.yml` file and change the `TDM_PW` to `MeIndexer`. This is not as insecure as it would seem since the `tdm` user has few privileges. Optimally, one could change the password hash for the TDM user in the `tomcat-users.xml` file. Also endure `TDS_HOST` is pointing to the correct Azure Docker host (e.g., `http://unidata-server.cloudapp.net`).

### `chown` for Good Measure<a id="orgheadline39"></a>

As we are approaching completion, let's ensure all files in `/home/ubuntu` are owned by the `ubuntu` user in the `docker` group.

```sh
sudo chown -R ubuntu:docker /home/ubuntu
```

### Pull Down Images from the DockerHub Registry<a id="orgheadline40"></a>

You are almost ready to run the whole kit and caboodle. But first  pull the relevant docker images to make this easier for the subsequent `docker-compose` command.

```sh
# Docker pull all relavant images
docker pull unidata/ldmtds:latest
docker pull unidata/tdm:latest
docker pull unidata/tds:latest
docker pull unidata/ramadda:latest
```

### Start the LDM, TDS, TDM, RAMADDA<a id="orgheadline41"></a>

We are now finally ready to start the LDM, TDS, TDM, RAMADDA with the following `docker-compose` command.

```sh
# Start up all images
docker-compose -f ~/git/Unidata-Dockerfiles/ams2016/docker-compose.yml up -d
```

# <a id="orgtarget4"></a>Check What is Running<a id="orgheadline52"></a>

In this section, we will assume you have created a VM called `unidata-server`.You should have these services running:

-   LDM
-   TDS
-   TDM
-   RAMADDA

Next, we will check our work through various means.

## Docker Process Status<a id="orgheadline43"></a>

From the shell where you started `docker-machine` earlier you can execute the following `docker ps` command to list the containers on your docker host. It should look something like the output below.

```sh
docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}"
```

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />

<col  class="org-right" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">CONTAINER ID</th>
<th scope="col" class="org-left">IMAGE</th>
<th scope="col" class="org-left">STATUS</th>
<th scope="col" class="org-right">&#xa0;</th>
<th scope="col" class="org-left">&#xa0;</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">d192f310d3a6</td>
<td class="org-left">unidata/mcidas</td>
<td class="org-left">Up</td>
<td class="org-right">10</td>
<td class="org-left">days</td>
</tr>


<tr>
<td class="org-left">7615f31c5bf8</td>
<td class="org-left">unidata/ramadda:latest</td>
<td class="org-left">Up</td>
<td class="org-right">13</td>
<td class="org-left">days</td>
</tr>


<tr>
<td class="org-left">9dbd4e83f15b</td>
<td class="org-left">unidata/ldmtds:latest</td>
<td class="org-left">Up</td>
<td class="org-right">13</td>
<td class="org-left">days</td>
</tr>


<tr>
<td class="org-left">dbcd457abe75</td>
<td class="org-left">unidata/tdm:latest</td>
<td class="org-left">Up</td>
<td class="org-right">13</td>
<td class="org-left">days</td>
</tr>


<tr>
<td class="org-left">5a4a13b5671e</td>
<td class="org-left">unidata/tds:latest</td>
<td class="org-left">Up</td>
<td class="org-right">12</td>
<td class="org-left">days</td>
</tr>
</tbody>
</table>

## Checking Data Directory<a id="orgheadline44"></a>

If you used the configuration described herein, you will have a `/data/ldm` directory tree that looks something like this created by the LDM:

```sh
tree --charset=ASCII  -L 3  /data/ldm -d -I '*2015*|*2016*|current'
```

    /data/ldm
    `-- pub
        `-- native
            |-- grid
            |-- radar
            `-- satellite
    
    5 directories

Poke around for GRIB2 data.

```sh
find /data/ldm -name *.grib2 | awk 'BEGIN { FS = "/" } ; { print $NF }' | head
```

    RR_CONUS_13km_20151216_2200.grib2
    RR_CONUS_13km_20151216_2100.grib2
    RR_CONUS_13km_20151216_2000.grib2
    RR_CONUS_13km_20151216_2300.grib2
    GFS_Global_onedeg_20151216_1800.grib2
    Level3_Composite_N0R_20151217_0000.grib2
    Level3_Composite_N0R_20151217_0005.grib2
    Level3_Composite_N0R_20151217_0010.grib2
    Level3_Composite_N0R_20151216_2155.grib2
    Level3_Composite_N0R_20151216_2315.grib2

Search for GRIB index files (`gbx9`). If you do not see them, see the section about a [finicky TDM](#orgtarget8) in the in the Appendix.

```sh
find /data/ldm -name *.gbx9 | awk 'BEGIN { FS = "/" } ; { print $NF }' | head
```

    RR_CONUS_13km_20151216_2200.grib2.gbx9
    RR_CONUS_13km_20151216_2300.grib2.gbx9
    RR_CONUS_13km_20151216_2100.grib2.gbx9
    RR_CONUS_13km_20151216_2000.grib2.gbx9
    GFS_Global_onedeg_20151216_1800.grib2.gbx9
    Level3_Composite_N0R_20151217_0005.grib2.gbx9
    Level3_Composite_N0R_20151217_0000.grib2.gbx9
    Level3_Composite_N0R_20151216_2205.grib2.gbx9
    Level3_Composite_N0R_20151216_2315.grib2.gbx9
    Level3_Composite_N0R_20151216_2330.grib2.gbx9

## TDS and RAMADDA URLs<a id="orgheadline45"></a>

Verify what you have the TDS and RAMADDA running by, for example, navigating to: <http://unidata-server.cloudapp.net/thredds/catalog.html> and <http://unidata-server.cloudapp.net:8081/repository>. If you are going to RAMADDA for the first time, you will have to do some [RAMADDA set up](http://ramadda.org//repository/userguide/toc.html).

## Viewing Data with the IDV<a id="orgheadline51"></a>

Another way to verify your work is run the [Unidata Integrated Data Viewer](https://www.unidata.ucar.edu/software/idv/).

### Access TDS with the IDV<a id="orgheadline46"></a>

In the [IDV Dashboard](https://www.unidata.ucar.edu/software/idv/docs/userguide/data/choosers/CatalogChooser.html), you should be able to enter the catalog XML URL: <http://unidata-server.cloudapp.net/thredds/catalog.xml>.  

### Access RAMADDAA with the IDV<a id="orgheadline50"></a>

RAMADDA has good integration with the IDV and the two technologies work well together. You may wish to install the [RAMADDA IDV plugin](http://www.unidata.ucar.edu/software/idv/docs/workshop/savingstate/Ramadda.html) to publish IDV bundles to RAMADDA. RAMADDA also has access to the `/data/ldm` directory so you may want to set up [server-side view of this part of the file system](http://ramadda.org//repository/userguide/developer/filesystem.html). Finally,  you can enter this catalog URL in the IDV dashboard to examine data holdings shared bundles, etc. on RAMADDA <http://unidata-server.cloudapp.net:8081/repository?output=thredds.catalog>.

1.  RAMADDA IDV Plugin

    You may wish to install the [RAMADDA IDV plugin](http://www.unidata.ucar.edu/software/idv/docs/workshop/savingstate/Ramadda.html) to publish IDV bundles to RAMADDA from directly within the IDV.

2.  RAMADDA Server Side Views

    RAMADDA also has access to the `/data/ldm` directory so you may want to set up [server side view of this part of the file system](http://ramadda.org//repository/userguide/developer/filesystem.html). It is a two step process where administrators go to the Admin, Access, File Access menu item and lists the allowed directories they potentially wish to expose via RAMADDA. Second, the users are now capable of creating a "Server Side" Files with the usual RAMADDA entry creation mechanisms.

3.  RAMADDA Catalog Views from the IDV

    Finally,  you can enter this catalog URL in the IDV dashboard to examine data holdings shared bundles, etc. on RAMADDA. For example, <http://unidata-server.cloudapp.net:8081/repository?output=thredds.catalog>.

# Appendix<a id="orgheadline60"></a>

## Common Problems<a id="orgheadline57"></a>

### <a id="orgtarget5"></a>Certificate Regeneration<a id="orgheadline53"></a>

When using `docker-machine`  may see an error message pertaining to regenerating certificates.

    Error running connection boilerplate: Error checking and/or regenerating the
    certs: There was an error validating certificates for host
    "host.cloudapp.net:2376": dial tcp 104.40.58.160:2376: i/o timeout You can
    attempt to regenerate them using 'docker-machine regenerate-certs name'.  Be
    advised that this will trigger a Docker daemon restart which will stop running
    containers.

In this case:

```sh
docker-machine regenerate-certs <azure-host>
eval "$(docker-machine env <azure-host>)"
```

Like the error message says, you may need to restart your Docker containers with `docker-compose`, for example.

### Size of VM is not Large Enough<a id="orgheadline54"></a>

If you see your containers not starting on Azure or error messages like this:

    ERROR: Cannot start container
    ef229d1753b24b484687ac4d6b8a9f3b961f2981057c59266c45b9d548df4e24: [8] System
    error: fork/exec /proc/self/exe: cannot allocate memory

it is possible you did not create a sufficiently large VM. Try  [increasing the size of the VM](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-size-specs/) .

### <a id="orgtarget8"></a>Where is my Data and the Finicky TDM<a id="orgheadline55"></a>

If you are not finding the data you expect to see via the THREDDS `catalog.xml` tree, check the TDM logs in `~/tdsconfig/logs/`. Also try restarting the containers on the Azure Docker host as directories may have been added by the LDM after TDS/TDM start up which the TDS/TDM apparently does not like:

```sh
cd ~/git/Unidata-Dockerfiles/ams2016
docker-compose stop
# remove stopped containers
docker-compose rm -f
# ensure containers are no longer running with
docker-compose ps -a
docker-compose up -d
```

You may also just have to **wait**. It can take a few hours for the TDM to catch up to what is going on in the `/data/ldm` directory.

### Cannot connect to the Docker daemon<a id="orgheadline56"></a>

    Cannot connect to the Docker daemon. Is the docker daemon running on this host?

[You may have simply forgotten to logout/login.](#orgtarget6)

## Asking for Help<a id="orgheadline58"></a>

For problems, help, questions, please submit an [issue on github](https://github.com/Unidata/Unidata-Dockerfiles/issues).

## Acknowledgments<a id="orgheadline59"></a>

-   National Science Foundation (Grant NSF-1344155)
-   Microsoft "Azure for Research" program
-   Tom Yoksas for Unidata operations expertise
