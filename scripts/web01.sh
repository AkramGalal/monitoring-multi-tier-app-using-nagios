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
