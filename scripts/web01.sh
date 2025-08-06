#! /usr/bin/bash
echo "Starting Script file"

sudo -i

# Update OS with latest patches
apt update -y
apt upgrade -y

# Install nginx
apt install nginx -y

# Create Nginx conf file
cat > /etc/nginx/sites-available/vproapp << EOF
upstream vproapp {
server app01:8080;
}
server {
listen 80;
location / {
proxy_pass http://vproapp;
}
}
EOF

# Remove default nginx conf
rm -rf /etc/nginx/sites-enabled/default

# Create link to activate website
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

# Restart Nginx
systemctl restart nginx

# Install Nagios plugin NRPE (Nagios Remote Plugin Executor)
sudo apt update -y
sudo apt install nrpe nagios-plugins-ping nagios-plugins-ssh nagios-plugins-http nagios-plugins-load nagios-plugins-disk nagios-plugins-procs -y

# Allow accessibility from the Nagios server to the VM to perform monitoring actions.
sudo cat >> /etc/nagios/nrpe.cfg <<EOF
allowed_hosts=127.0.0.1,192.168.56.10
EOF

# Define the definition of check_command in the configuration file of the NRPE plugin 
cat >> /etc/nagios/nrpe.cfg << EOF
command[check_nginx]=/usr/lib/nagios/plugins/check_procs -c 1: -C nginx
EOF

# Restart NRPE service
sudo systemctl restart nrpe
sudo systemctl enable nrpe
