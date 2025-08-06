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

# Install Nagios plugin NRPE (Nagios Remote Plugin Executor)
sudo dnf update -y
sudo dnf install nrpe nagios-plugins-ping nagios-plugins-ssh nagios-plugins-http nagios-plugins-load nagios-plugins-disk nagios-plugins-procs -y

# Allow accessibility from the Nagios server to the VM to perform monitoring actions.
sudo cat >> /etc/nagios/nrpe.cfg <<EOF
allowed_hosts=127.0.0.1,192.168.56.10
EOF

# Define the definition of check_command in the configuration file of the NRPE plugin 
cat >> /etc/nagios/nrpe.cfg << EOF
command[check_memcached]=/usr/lib64/nagios/plugins/check_procs -c 1: -C memcached 
EOF

# Restart NRPE service
sudo systemctl restart nrpe
sudo systemctl enable nrpe