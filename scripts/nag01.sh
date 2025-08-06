#! /usr/bin/bash
echo "Starting Nagios Script file"

sudo -i

# Update OS with latest patches
apt update -y
apt upgrade -y

# Install important building libraries needed by Nagios
sudo apt install build-essential libssl-dev pkg-config libgd-dev libpng-dev libjpeg-dev unzip apache2 php libapache2-mod-php -y

# create Nagios user and groups that use Nagios service
sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
sudo usermod -a -G nagcmd www-data

# nstall and configure Nagios Core latest version
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.5.9.tar.gz
tar xzf nagios-4.5.9.tar.gz
cd nagios-4.5.9
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
sudo make install
sudo make install-init
sudo make install-commandmode
sudo make install-config
sudo mkdir -p /etc/apache2/sites-enabled
sudo make install-webconf
sudo a2enmod rewrite cgi
sudo systemctl restart apache2

# Create Nagios web interface user and password
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

# Install Nagios plugins
cd /tmp
wget https://nagios-plugins.org/download/nagios-plugins-2.4.11.tar.gz
tar xzf nagios-plugins-2.4.11.tar.gz
cd nagios-plugins-2.4.11
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
sudo make install

# Install NRPE plugin for remote checks
sudo apt install -y nagios-nrpe-plugin

# Enable and start Nagios service
sudo systemctl enable nagios
sudo systemctl start nagios

# Add Nagios Hosts
cat >> /usr/local/nagios/etc/objects/hosts.cfg << EOF
define host {
    use                     generic-host
    host_name               node1-Ngnix
    alias                   Ngnix Web Server
    address                 192.168.56.11
    check_command           check_nrpe!check_ping
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
}

define host {
    use                     generic-host
    host_name               node2-App
    alias                   Application Web Server
    address                 192.168.56.12
    check_command           check_nrpe!check_ping
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
}

define host {
    use                     generic-host
    host_name               node3-RMQ
    alias                   RabbitMQ Server
    address                 192.168.56.13
    check_command           check_nrpe!check_ping
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
}

define host {
    use                     generic-host
    host_name               node4-MemCache
    alias                   MemCache Server
    address                 192.168.56.14
    check_command           check_nrpe!check_ping
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
}

define host {
    use                     generic-host
    host_name               node5-DB
    alias                   DataBase Server
    address                 192.168.56.15
    check_command           check_nrpe!check_ping
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
}
EOF

# Add Services to Nagios 
cat >> /usr/local/nagios/etc/objects/services.cfg << EOF
## Node1 - Nginx
define service {
    use                     generic-service
    host_name               node1-Ngnix
    service_description     Nginx Service
    check_command           check_nrpe!check_nginx
}

## Node2 - Tomcat
define service {
    use                     generic-service
    host_name               node2-App
    service_description     Tomcat Service
    check_command           check_nrpe!check_tomcat
}

## Node3 - RabbitMQ
define service {
    use                     generic-service
    host_name               node3-RMQ
    service_description     RabbitMQ Service
    check_command           check_nrpe!check_rabbitmq
}

## Node4 - Memcached
define service {
    use                     generic-service
    host_name               node4-MemCache
    service_description     Memcached Service
    check_command           check_nrpe!check_memcached
}

## Node5 - MariaDB
define service {
    use                     generic-service
    host_name               node5-DB
    service_description     MariaDB Service
    check_command           check_nrpe!check_mysql
}
EOF

# The definition of check_command in "commands.cfg" file 
cat >> /usr/local/nagios/etc/objects/commands.cfg << EOF

define command {
    command_name    check_nrpe
    command_line    $USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$
}
EOF

# Adjust Nagios configuration to point out "host.cfg" and "services.cfg" files
cat >> /usr/local/nagios/etc/nagios.cfg << EOF
cfg_file=/usr/local/nagios/etc/objects/hosts.cfg 
cfg_file=/usr/local/nagios/etc/objects/services.cfg
EOF

# Restart Nagios to apply changes
sudo systemctl restart nagios
sudo systemctl enable nagios

# Confirmation message
echo "Nagios Hosts and Services are configured successfully."