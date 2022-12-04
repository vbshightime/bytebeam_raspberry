#!/bin/bash
#sudo apt update && sudo apt -y upgrade

set -ex

DEFAULT_USR_DIR=/usr/share/bytebeam
DEFAULT_CONFIG_DIR=/etc/bytebeam
DEFAULT_HOME_DIR=/home/pi

mkdir -p $DEFAULT_USR_DIR $DEFAULT_CONFIG_DIR

# download uplink pre built binaries for raspberry pi

if [ ! -f /usr/share/bytebeam/uplink ]; then
    wget -O /usr/share/bytebeam/uplink  https://github.com/bytebeamio/uplink/releases/download/v1.4.1/uplink-armv7-unknown-linux-gnueabihf
else
    read -p "File already exists do you want to replace? (y/n) " usr_in
    case $usr_in in
        y ) sudo rm -rf /usr/share/bytebeam/uplink;
            wget -O /usr/share/bytebeam/uplink  https://github.com/bytebeamio/uplink/releases/download/v1.4.1/uplink-armv7-unknown-linux-gnueabihf;;
        n ) echo "proceed";;
        * ) echo "proceed";;
    esac
fi

# make uplink executable
chmod +x /usr/share/bytebeam/uplink


#enable and start uplink service
sudo install -m 644 uplink.service /etc/systemd/system
sudo systemctl enable uplink.service

