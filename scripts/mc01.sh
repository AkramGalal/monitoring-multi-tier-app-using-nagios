#! /usr/bin/bash

sudo -i 

# Update OS with latest patches
yum update -y

# Install, start & enable memcache on port 11211
sudo dnf install epel-release -y
sudo dnf install memcached -y
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached