#!/bin/bash
# Custom Script to set up a Kafka instance on an Ubuntu Distribution
# Peter Lyssikatos - 9/6/2021

DLDIR='~/downloads'
KDIR='~/kafka'
DLDIR='/home/kafka/downloads'
KDIR='/home/kafka/kafka'
USER='kafka'
TARFILE='kafka.tgz'
VER='2.6.2'
# Version prefix
PVER='2.13'
DLURL="https://downloads.apache.org/kafka/$VER/kafka_$PVER$VER.tgz"
PROP='~/kafka/config/server.properties'
DLURL="https://downloads.apache.org/kafka/2.6.2/kafka_2.13-2.6.2.tgz"
PROPS='home/kafka/kafka/config/server.properties'
# Log destination
LOGDEST='/home/kafka/logs'
LOGDEST='home/kafka/kafka/logs'
# Zookeeper service path
ZKPATH='/etc/systemd/system/zookeeper.service'
KPATH='/etc/systemd/system/zookeeper.service'
KPATH='/etc/systemd/system/kafka.service'
# Unit file def for Zookeeper
ZKUDEF=$(cat << EOF
[Unit]\n
@@ -51,63 +51,51 @@ WantedBy=multi-user.target
EOF
)


echo "Please enter sudo password"
read SUDOPASS
# Create kafka user
# If user does not exist create a Kafka user
if getent passwd | grep -C "^$User" = 1;
if getent passwd $USER;
then
    echo "$USER already exists"
else
    echo 'No user exists please enter your password to create one'
    sudo adduser $USER
    echo "$USER successfully created..."
    sudo adduser kafka sudo
    sudo adduser $USER sudo
    echo "$USER added to sudo group"
fi

su -l $USER
echo "signed in as $USER"

# Download and Extract Kafka Binaries
# Create a downloads dir if it does note exist
if [!-d "$DLDIR"];
then
    mkdir $DLDIR
    echo "$DLDIR created..."
else
    echo "$DLDIR exists"
fi
# Create a downloads dir if it does not exist
echo $SUDOPASS | sudo -S mkdir -p "${DLDIR}"

# curl Kafka binaries
curl $DLURL -o $DLDIR/$TARFILE

# Create and enter the kafka dir
if [!-d "$KDIR"];
if [ -n "$(ls -A $KDIR/bin)" ];
then
    mkdir $KDIR && cd $KDIR
    echo "$KDIR created..."
    echo "no need to download"
else
    echo "$KDIR exists"
    echo $SUDOPASS | sudo -S curl $DLURL -o $DLDIR/$TARFILE
    echo $SUDOPASS | sudo -S mkdir -p "${KDIR}"
    # Extract the binaries
    echo $SUDOPASS | sudo -S tar -xvzf $DLDIR/$TARFILE -C $KDIR --strip 1
fi
cd $KDIR
echo "$KDIR entered"

# Extract the binaries
tar -xvzf $DLDIR/$TARFILE --strip 1

# Configure Kafka
# configure Kafka
echo "Would you like to configure $TARFILE?\n(This will allow you to delte topics and setup logs)"
read CONFIG
if $CONFIG =~ ?=Y?=y?=yes?=Yes$;
if [ "$CONFIG" = "yes" ];
then
    sed -i 's/delete.topic.enable = false/delete.topic.enable = true/g' $PROPS
    if grep -q 'delete.topic.enable = true' $PROPS
    echo $SUDOPASS | sudo -S echo 'delete.topic.enable = true' >> echo $SUDOPASS | sudo -S tee -a $PROPS
    if grep -q 'delete.topic.enable=true' $PROPS;
    then
        echo 'Delete topic has been enabled'
    else
        echo 'ERROR'
    fi
    grep 'delete.topic.enable*' $PROPS
    sed -i "s/log.dirs=*/log.dirs=$LOGSDEST" $PROPS
    if grep -q "log.dirs=$LOGDEST" $PROPS
    if grep -q "log.dirs=$LOGDEST" $PROPS;
    then
        echo "$LOGDEST set"
    else
@@ -121,11 +109,11 @@ fi
# Create Systemd Unit Files and Start the Kafka Server
echo "Would you like to create systemd Unit files?"
read UNITFILES
if $UNITFILES =~ ?=Y?=y?=yes?=Yes$;
if [ "$UNITFILES" = "yes" ];
then
    sudo touch $ZKPATH
    echo $SUDOPASS | sudo -S touch $ZKPATH
    echo $ZKUDEF > $ZKPATH
    sudo touch $KPATH
    echo $SUDOPASS | sudo -S touch $KPATH
    echo $KUDEF > $KUDEF
    cat $ZKPATH
    cat $KPATH
@@ -134,16 +122,16 @@ else
fi
echo 'would you like to start kafka server?'
read START
if $START =~ ?=Y?=y?=yes?=Yes$;
if $START = "yes"
then
    sudo systemctl start kafka
    echo $SUDOPASS | sudo -S systemctl start kafka
    if sudo grep -q Active: active | systemctl status kafka
    then
        echo "Kafka is running successfully!"
    else
        echo "ERROR"
    fi
    sudo systemctl status kafka
    echo $SUDOPASS | sudo -S systemctl status kafka
else
    echo 'You have chosen not to start kafka you can always start it manually.'
fi
