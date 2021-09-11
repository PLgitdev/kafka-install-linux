#!/bin/bash
# Custom Script to set up a Kafka instance on an Ubuntu Distribution
# Peter Lyssikatos - 9/6/2021

DLDIR='/home/kafka/downloads'
KDIR='/home/kafka/kafka'
USER='kafka'
TARFILE='kafka.tgz'
VER='2.6.2'
# Version prefix
PVER='2.13'
DLURL="https://downloads.apache.org/kafka/2.6.2/kafka_2.13-2.6.2.tgz"


echo "Please enter sudo password"
read SUDOPASS
# Create kafka user
# If user does not exist create a Kafka user
if getent passwd $USER;
then
    echo "$USER already exists"
else
    echo 'No user exists please enter your password to create one'
    sudo adduser $USER
    echo "$USER successfully created..."
    sudo adduser $USER sudo
    echo "$USER added to sudo group"
fi
# Download and Extract Kafka Binaries
# Create a downloads dir if it does not exist
echo $SUDOPASS | sudo -S mkdir -p "${DLDIR}"

# curl Kafka binaries
if [ -n "$(ls -A $KDIR/bin)" ];
then
    echo "no need to download"
else
    echo $SUDOPASS | sudo -S curl $DLURL -o $DLDIR/$TARFILE
    echo $SUDOPASS | sudo -S mkdir -p "${KDIR}"
    # Extract the binaries
    echo $SUDOPASS | sudo -S tar -xvzf $DLDIR/$TARFILE -C $KDIR --strip 1
fi

exit 1
