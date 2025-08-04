#! /usr/bin/bash
echo "Starting Script file"

sudo -i

# Update OS with latest patches
apt update -y
apt upgrade -y

# Install important building libraries needed by Nagios
sudo apt install -y build-essential libssl-dev pkg-config libgd-dev libpng-dev libjpeg-dev unzip






