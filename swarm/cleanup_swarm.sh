#!/bin/bash
# Utility script to clean up swarm stuff.

###
# Help Function
###
DOHELP()
{
    echo ""
    echo "Usage: $0 -hq -nmefa"
    echo -e "\t-h\t Show this help dialog."
    echo -e "\t-q\t Perform a practice run."
    echo ""
    echo -e "\t-n\t Delete all compute nodes."
    echo -e "\t-m\t Delete all master nodes."
    echo -e "\t-e\t Delete all environment nodes."
    echo -e "\t-f\t Delete all log, diagnostic files."
    echo -e "\t-a\t Delete ALL OF THE ABOVE."
    echo ""
    echo ""
    echo "NOTE: THIS SCRIPT USES STRING MATCHING TO"
    echo "      DELETE FILES AND DOCKER SERVERS."
    echo "      IT IS POTENTIALLY NOT SAFE! MAKE"
    echo "      SURE YOU KNOW WHAT YOU'RE DOING!"
    echo ""
}

###
# Print out a summary.
###
DOSUMMARIZE()
{
    echo ""
    echo "SUMMARY"
    echo "===================="
    echo -e "Clean Compute Nodes:\t\t$DOCOMPUTE"
    echo -e "Clean Master Nodes:\t\t$DOMASTER"
    echo -e "Clean Environment Nodes:\t$DOENV"
    echo -e "Clean Files:\t\t\t$DOFILES"
    echo -e "Practice Run:\t\t\t$DOPRAC"
    echo "===================="
    echo ""
}

###
# Initialize Internal Variables
###
DOCOMPUTE="FALSE"
DOMASTER="FALSE"
DOENV="FALSE"
DOFILES="FALSE"
DOPRAC="FALSE"

if [ $# -lt 1 ]; then
    DOHELP
    exit 0
fi

###
# Parse Options
###
while getopts "nmefaq" o; do
    case "${o}" in
        n)
            DOCOMPUTE="TRUE"
            ;;
        m)
            DOMASTER="TRUE"
            ;;
        e)
            DOENV="TRUE"
            ;;
        f)
            DOFILES="TRUE"
            ;;
        a)
            DOCOMPUTE="TRUE"
            DOMASTER="TRUE"
            DOENV="TRUE"
            DOFILES="TRUE"
            ;;
        q)
            DOPRAC="TRUE"
            ;;
        *)
            DOHELP
            exit 0
    esac
done

DOSUMMARIZE

if [ "x$DOPRAC" == "xTRUE" ]; then
    echo "Exiting Practice Run"
    echo ""
    exit 0
fi

##
# Delete compute nodes.
##
if [ "x$DOCOMPUTE" == "xTRUE" ]; then
    echo "Deleting Compute Nodes"
    echo "----------------------"
    set -x
    docker-machine rm -f $(docker-machine ls -q | grep swarm-node)
    set +x
    echo ""
fi

##
# Delete compute nodes.
##
if [ "x$DOMASTER" == "xTRUE" ]; then
    echo "Deleting Master Nodes"
    echo "---------------------"
    set -x
    docker-machine rm -f $(docker-machine ls -q | grep swarm-master)
    set +x
    echo ""
fi

##
# Delete environment nodes.
##
if [ "x$DOENV" == "xTRUE" ]; then
    echo "Deleting Environment Nodes"
    echo "--------------------------"
    set -x
    docker-machine rm -f $(docker-machine ls -q | grep swarm-env)
    set +x
    echo ""
fi

##
# Delete files.
##
if [ "x$DOFILES" == "xTRUE" ]; then
    echo "Deleting Files"
    echo "--------------"
    set -x
    rm -f ./swarm-log*.txt
    rm -f ./swarm-stats*.txt
    rm -f ./token*.sh
    rm -f ./master-env-*.sh
    rm -f ./*openports-tmp.sh
    rm -f ./*~
    set +x
    echo ""
fi

echo "Finished."
