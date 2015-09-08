#!/bin/bash
##########
# Utility script to create a docker swarm
# using docker and docker machine.
##########


set -e

###
# Write a help function.
###
DOHELP()
{
    echo ""
    echo "Usage: $0 -cxqe -l [location] -t [token string] -n [# of nodes to create]"
    echo -e "\t -t\t Specify a token to use. It is generated if not specified."
    echo -e "\t   \t   (you must have a default docker machine running or"
    echo -e "\t   \t   (specify the creation of one with '-e')"
    echo -e "\t -e\t Specify that an env node needs to be created."
    echo -e "\t -n\t Number of compute nodes to create."
    echo -e "\t -c\t Only generate compute nodes, no master node."
    echo -e "\t -x\t Disable showing log files in new xterm windows."
    echo -e "\t -q\t Do a practice run, don't actually make any changes."
    echo -e "\t -h\t Show this help information."
    echo -e ""
    echo -e "\t -l\t Location to create node."

    echo -e "\t   \t\to local [default]"
    echo -e "\t   \t\t\t-m RAM for compute nodes. Default: 2048"
    echo -e "\t   \t\t\t-p Processor count for nodes. Default: -1"

    echo -e "\t   \t\to rackspace"

    echo -e "\t   \t\to azure"
    echo -e "\t   \t\t+ Azure-specific options:"
    echo -e "\t   \t\t\t-s Azure VM size [default: Basic_A3]"
    echo -e "\t   \t\t\t-i Azure Image Name [default: Ubuntu 14.04 LTS x64"
    echo -e "\t   \t\t+ Azure-specific Assumptions:"
    echo -e "\t   \t\t\t1. AZURE_SUB_KEY is defined."
    echo -e "\t   \t\t\t2. $HOME/.azure-docker/ is created and configured."
    echo ""
}

DOSUMMARIZE()
{
    echo ""
    echo "SUMMARY"
    echo "============================="
    echo -e "Location:\t$NODELOC"
    echo -e "Logfile:\t$LOGFILE"
    echo -e "Master Node:\t$DOMASTER"
    echo -e "Total Nodes:\t$TOTALNODES"
    echo -e "Node Loc:\t$NODELOC"
    if [ "x$NODELOC" == "xlocal" ]; then
        echo -e "Node RAM:\t$NODERAM (MB)"
        echo -e "Node Procs:\t$PROCCOUNT"
    fi
    if [ "x$NODELOC" == "xazure" ]; then
        echo -e "Azure Size:\t$AZURESIZE"
        echo -e "Azure Image:\t$AZUREIMG"
    fi
    #if [ "x$NODELOC" == "xrackspace" ]; then
    #
    #fi
    echo -e ""
    echo -e "Env File:\t$EDMFILE"
    echo -e "Token File:\t$TOKENFILE"
    echo -e "Token:\t\t$TOKEN"
    echo -e ""
    echo -e "Docker CMD:\t$DOCKERCMD"

    echo "============================="
    echo ""
}

###
# Generate random string to use as a suffix
# for log files and node/machine names.
###
if type "openssl" > /dev/null; then
    RSTRING="$(openssl rand -hex 3)"
elif type "date" > /dev/null; then
    RSTRING="$(date +%s)"
else
    RSTRING="NOTRAND"
fi

RSTRINGSHORT="$(echo $RSTRING | head -c 3)"

###
# Define some internal variables.
###

# Docker VM/machine names and location
SWARMENVNAME="default"

# Log files, etc.
LOGFILE="swarm-log-$RSTRING.txt"
STATFILE="swarm-stats-$RSTRING.txt"
TOKENFILE="token-$RSTRING.sh"
EDMFILE="master-env-$RSTRINGSHORT.sh"

echo "Logfile: $LOGFILE"
echo "Stat File: $STATFILE"
NODELOC="local"



###
# Initialize some variables.
###

DOPRAC=""
TOKEN=""
TOTALNODES=""
DOMASTER="TRUE"
USEX="TRUE"
CREATEENV="FALSE"
NODERAM="2048"
PROCCOUNT="-1"
AZURESIZE="Basic_A3"
AZUREIMG="Ubuntu 14.04 LTS x64"
DOCKERCMD=""

###
# Parse Options
###
while getopts "cxt:n:qhem:p:l:s:i:" o; do
    case "${o}" in
        c)
            DOMASTER="FALSE"
            ;;
        x)
            USEX="FALSE"
            ;;
        t)
            TOKEN=${OPTARG}
            ;;
        m)
            NODERAM=${OPTARG}
            ;;
        p)
            PROCCOUNT=${OPTARG}
            ;;
        n)
            TOTALNODES=${OPTARG}
            ;;
        q)
            DOPRAC="TRUE"
            ;;
        e)
            CREATEENV="TRUE"
            ;;
        l)
            NODELOC=${OPTARG}
            ;;
        s)
            AZURESIZE=${OPTARG}
            ;;
        i)
            AZUREIMG=${OPTARG}
            ;;
        *)
            DOHELP
            exit 0
    esac
done

#####
# Print Summary if need be.
#####
if [ "x$DOPRAC" == "xTRUE" ]; then
    DOSUMMARIZE $TOKEN
    exit 0
fi

#####
# Bail if number of nodes wasn't specified.
#####
if [ "x$TOTALNODES" == "x" ]; then
    DOHELP
    exit 0
fi

echo "$(date)" > $LOGFILE
echo "$(date)" > $STATFILE

if [ "x$USEX" == "xTRUE" ]; then
    xterm -T "[LOGFILE]: $LOGFILE" -bg black -fg white -geometry 80x20+10+10 -e tail -f $LOGFILE &
fi

#####
# Create the docker container crate, from which we obtain the token.
#####

if [ "x$TOKEN" == "x" ]; then

    if [ "x$CREATEENV" == "xTRUE" ]; then
        echo "Creating Swarm Environment Node" >> $STATFILE
        SWARMENVNAME="swarm-env-$RSTRING"
        docker-machine -D create -d virtualbox --virtualbox-memory 512 --virtualbox-cpu-count 1 "$SWARMENVNAME" 1 >> $LOGFILE 2>&1
        echo "Finished."
        echo ""
    else
        echo "Getting Swarm Environment from existing node: $SWARMENVNAME"
        echo "Getting Swarm Environment from existing node: $SWARMENVNAME" >> $LOGFILE
    fi

    eval "$(docker-machine env $SWARMENVNAME)"
    TOKEN="$(docker run swarm create)"

fi
##
# Create a script we can 'eval' to get the token.
##

TOKENFILE="token-$RSTRING-$(echo $TOKEN | head -c 6).sh"

echo "Using Token: $TOKEN"
echo "Using Token: $TOKEN" >> $STATFILE
echo "# Run '. \$(./$TOKENFILE)' to define the cluster" > $TOKENFILE
echo '# token variable, $TOKEN' >> $TOKENFILE
echo "echo $TOKEN" >> $TOKENFILE
echo "echo export TOKEN=$TOKEN" >> $TOKENFILE
echo "export TOKEN=$TOKEN" >> $TOKENFILE

chmod 755 $TOKENFILE
cp $TOKENFILE token-latest.sh


###
# Determine what the Docker command will be.
###
case "$NODELOC" in
    local)
        DOCKERCMD="docker-machine -D create -d virtualbox --virtualbox-memory ${NODERAM} --virtualbox-cpu-count ${PROCCOUNT} --swarm --swarm-discovery token://${TOKEN}"
        ;;
    rackspace)
        DOCKERCMD="docker-machine -D create -d rackspace --rackspace-region ORD --rackspace-username ${RACKSPACE_USER} --swarm --swarm-discovery token://${TOKEN}"
        ;;
    azure)
        DOCKERCMD="docker-machine -D create -d azure --azure-subscription-id=$AZURE_SUB_KEY --azure-subscription-cert=$HOME/.azure-docker/mycert.pem --swarm --swarm-discovery token://${TOKEN} --azure-size=$AZURESIZE"
        ;;
    *)
        echo "Unknown location: $NODELOC"
        DOHELP
        exit 0
esac

echo ""
echo "Using Docker Command: $DOCKERCMD"
echo "Using Docker Command: $DOCKERCMD" >> $STATFILE
echo ""

#####
# Create the swarm master.
#####

if [ "x$DOMASTER" == "xTRUE" ]; then

    echo "Creating Swarm Master Node" >> $STATFILE
    $DOCKERCMD --swarm-master "swarm-master-$RSTRINGSHORT" >> $LOGFILE 2>&1
    echo "Finished." >> $STATFILE
    echo ""

    ##
    # Create a script we can 'eval' to activate the master node.
    ##
    echo "# $(date)" > $EDMFILE
    echo "echo Running \". $EDMFILE\" to activate master node environment." >> $EDMFILE
    echo "eval \$(docker-machine env --swarm swarm-master-$RSTRINGSHORT)" >> $EDMFILE

    chmod 755 $EDMFILE
    cp $EDMFILE master-env-latest.sh
fi

####
# Create swarm nodes.
####

NODECOUNT=1

while [[ $NODECOUNT -le $TOTALNODES ]]; do

    NODENAME="swarm-node$NODECOUNT-$RSTRING-$NODELOC"
    echo "Creating node $NODECOUNT of $TOTALNODES: $NODENAME"
    echo "Creating node $NODECOUNT of $TOTALNODES: $NODENAME" >> $STATFILE
    set -x
    xterm -T "[$NODENAME]" -bg black -fg white -geometry 80x20 -e $DOCKERCMD $NODENAME >> $LOGFILE 2>&1 &
    set +x
    sleep 5

    NODECOUNT=$[$NODECOUNT+1]
done

DOSUMMARIZE
echo "" >> $STATFILE
echo "Finished." >> $STATFILE

echo "" >> $LOGFILE
echo "Finished." >> $LOGFILE
