#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

usage="$(basename "$0") [-h] [-m, --mount device mount (e.g., /dev/sdb)] [-d, --directory directory to attach to device mount]  -- 
script to setup VMs.:\n
    -h  show this help text\n
    -m, --mount device mount.\n
    -d, --directory directory\n"

while [[ $# > 0 ]]
do
    key="$1"
    case $key in
        -m|--mount)
            MOUNT="$2"
            shift # past argument
            ;;
        -d|--directory)
            DIRECTORY="$2"
            shift # past argument
            ;;
        -h|--help)
            echo -e $usage
            exit
            ;;
    esac
    shift # past argument or value
done

if [ -z ${MOUNT+x} ];
  then
      echo "Must supply a device mount name:" 
      echo -e $usage
      exit 1
fi

if [ -z ${DIRECTORY+x} ];
   then
      echo "Must supply a directory name to attach to mount:" 
      echo -e $usage
      exit 1
fi

mkdir $DIRECTORY
fdisk -l $MOUNT
mkfs.ext4 $MOUNT
mount $MOUNT $DIRECTORY 
chown -R ubuntu:docker $DIRECTORY
