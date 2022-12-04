#!/bin/bash
#sudo apt update && sudo apt -y upgrade

set -ex

DEFAULT_USR_DIR=/usr/share/bytebeam
DEFAULT_CONFIG_DIR=/etc/bytebeam
DEFAULT_HOME_DIR=/home/pi
DEFAULT_TMP_DIR=/tmp/bytebeam
DEFAULT_REPO=/tmp/bytebeam_raspberry-main

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


while [ ! -f /usr/share/bytebeam/device_config.json ]; do
    echo "device_config.json does not appear here provision your device in bytebeam cloud and download device.json and place in /usr/share/bytebeam and then press any key to proceed"
    read key_pressed
done


#clone bytebeam repository
if [ ! -f /tmp/bytebeam.zip ]; then
    wget -O /tmp/bytebeam.zip  https://github.com/vbshightime/bytebeam_raspberry/archive/refs/heads/main.zip
fi

if [ ! -d /tmp/bytebeam_raspberry-main ]; then
    echo "file does not exists unzip it"
    unzip /tmp/bytebeam.zip -d /tmp
fi

#copy config.toml to DEFAULT_CONFIG_DIR
cp /tmp/bytebeam_raspberry-main/config.toml /etc/bytebeam/config.toml

#copy python application to DEFAULT_USR_DIR
cp /tmp/bytebeam_raspberry-main/app.py /usr/share/bytebeam/app.py

#now we need to configure config.ini and enter stream here
touch /tmp/configfile.ini
echo "[stream]" > /tmp/configfile.ini
read -p "Enter stream name: " stream_in
echo "stream_name = ${stream_in}" >> /tmp/configfile.ini

cat /tmp/configfile.ini

#copy config.ini to DEFAULT_USR_DIR
cp /tmp/configfile.ini /usr/share/bytebeam/configfile.ini

#enable and start uplink service
sudo install -m 644 /tmp/bytebeam_raspberry-main/uplink.service /etc/systemd/system
sudo systemctl enable uplink.service

#enable and start bytebeam app service

sudo install -m 644 /tmp/bytebeam_raspberry-main/bytebeam_app.service /etc/systemd/system
sudo systemctl enable bytebeam_app.service

#create and start cron job to reload and restart uplink systemctl service

touch /tmp/uplink-cron

echo "0 0 * * * root systemctl restart uplink" > /tmp/uplink-cron

cp -f /tmp/uplink-cron /etc/cron.d/uplink


