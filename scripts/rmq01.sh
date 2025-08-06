#! /usr/bin/bash

sudo -i

# Update OS with latest patches
yum update -y

# Set EPEL Repository
yum install epel-release -y

# Install Dependencies
yum install wget -y
cd /tmp/
dnf -y install centos-release-rabbitmq-38
dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
systemctl enable --now rabbitmq-server

# Setup access to user test and make it admin
sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
rabbitmqctl add_user test test
rabbitmqctl set_user_tags test administrator
systemctl restart rabbitmq-server

# Install Nagios plugin NRPE (Nagios Remote Plugin Executor)
sudo dnf update -y
sudo dnf install nrpe nagios-plugins-ping nagios-plugins-ssh nagios-plugins-http nagios-plugins-load nagios-plugins-disk nagios-plugins-procs -y

# Allow accessibility from the Nagios server to the VM to perform monitoring actions.
sudo cat >> /etc/nagios/nrpe.cfg <<EOF
allowed_hosts=127.0.0.1,192.168.56.10
EOF

# Define the definition of check_command in the configuration file of the NRPE plugin 
cat >> /etc/nagios/nrpe.cfg << EOF
command[check_rabbitmq]=/usr/lib64/nagios/plugins/check_procs -c 1: -C beam.smp 
EOF

# Restart NRPE service
sudo systemctl restart nrpe
sudo systemctl enable nrpe
