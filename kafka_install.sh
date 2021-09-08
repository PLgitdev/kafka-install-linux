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
PROPS='home/kafka/kafka/config/server.properties'
# Log destination
LOGDEST='home/kafka/kafka/logs'
# Zookeeper service path
ZKPATH='/etc/systemd/system/zookeeper.service'
KPATH='/etc/systemd/system/kafka.service'
# Unit file def for Zookeeper
ZKUDEF=$(cat << EOF
[Unit]\n
Requires=network.target remote-fs.target\n
After=network.target remote-fs.target\n
\n
[Service]\n
Type=simple\n
User=kafka\n
ExecStart=/home/kafka/kafka/bin/zookeeper-server-start.sh /home/kafka/kafka/config/zookeeper.properties\n
ExecStop=/home/kafka/kafka/bin/zookeeper-server-stop.sh\n
Restart=on-abnormal\n
\n
[Install]\n
WantedBy=multi-user.target\n
EOF
)
# Unit file def for Kafka
KUDEF=$(cat << EOF
[Unit]\n
Requires=zookeeper.service\n
After=zookeeper.service\n
\n
[Service]\n
Type=simple\n
User=kafka\n
ExecStart=/bin/sh -c '/home/kafka/kafka/bin/kafka-server-start.sh /home/kafka/kafka/config/server.properties > /home/kafka/kafka/kafka.log 2>&1'\n
ExecStop=/home/kafka/kafka/bin/kafka-server-stop.sh\n
Restart=on-abnormal\n
\n
[Install]\n
WantedBy=multi-user.target
EOF
)


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

# configure Kafka
echo "Would you like to configure $TARFILE?\n(This will allow you to delte topics and setup logs)"
read CONFIG
if [ "$CONFIG" = "yes" ];
then
    echo $SUDOPASS | sudo -S echo 'delete.topic.enable = true' >> echo $SUDOPASS | sudo -S tee -a $PROPS
    if grep -q 'delete.topic.enable=true' $PROPS;
    then
        echo 'Delete topic has been enabled'
    else
        echo 'ERROR'
    fi
    grep 'delete.topic.enable*' $PROPS
    sed -i "s/log.dirs=*/log.dirs=$LOGSDEST" $PROPS
    if grep -q "log.dirs=$LOGDEST" $PROPS;
    then
        echo "$LOGDEST set"
    else
        echo 'ERROR'
    fi
    grep "log.dirs=$LOGDEST" $PROPS
else
    echo "You have chosen not to configure $TARFILE you can always change it manually."
fi

# Create Systemd Unit Files and Start the Kafka Server
echo "Would you like to create systemd Unit files?"
read UNITFILES
if [ "$UNITFILES" = "yes" ];
then
    echo $SUDOPASS | sudo -S touch $ZKPATH
    echo $ZKUDEF > $ZKPATH
    echo $SUDOPASS | sudo -S touch $KPATH
    echo $KUDEF > $KUDEF
    cat $ZKPATH
    cat $KPATH
else
    echo 'You have chosen not to create the Unit files you can alawys change it manually.'
fi
echo 'would you like to start kafka server?'
read START
if $START = "yes"
then
    echo $SUDOPASS | sudo -S systemctl start kafka
    if sudo grep -q Active: active | systemctl status kafka
    then
        echo "Kafka is running successfully!"
    else
        echo "ERROR"
    fi
    echo $SUDOPASS | sudo -S systemctl status kafka
else
    echo 'You have chosen not to start kafka you can always start it manually.'
fi
echo "Goodbye"
exit 1
