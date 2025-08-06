#! /usr/bin/bash

sudo -i 

# Update OS with latest patches
yum update -y

# Set Repository
yum install epel-release -y

#Install Maria DB Package
yum install git mariadb-server -y

#Starting & enabling mariadb-server
systemctl start mariadb
systemctl enable mariadb

# Run mysql_secure_installation script automatically
echo "Securing MariaDB..."
expect <<EOF
spawn mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "\r"
expect "Set root password? \[Y/n\]"
send "y\r"
expect "New password:"
send "admin123\r"
expect "Re-enter new password:"
send "admin123\r"
expect "Remove anonymous users? \[Y/n\]"
send "y\r"
expect "Disallow root login remotely? \[Y/n\]"
send "y\r"
expect "Remove test database and access to it? \[Y/n\]"
send "y\r"
expect "Reload privilege tables now? \[Y/n\]"
send "y\r"
expect eof
EOF

# Set DB name and users.
mysql -u root -padmin123 <<SQL
create database accounts;
grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123';
FLUSH PRIVILEGES;
SQL

# Download Source code & Initialize Database.
git clone -b main https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project

mysql -u root -padmin123 accounts < src/main/resources/db_backup.sql
mysql -u root -padmin123 accounts

# Restart mariadb-server
systemctl restart mariadb


# Install Nagios plugin NRPE (Nagios Remote Plugin Executor)
sudo dnf update -y
sudo dnf install nrpe nagios-plugins-ping nagios-plugins-ssh nagios-plugins-http nagios-plugins-load nagios-plugins-disk nagios-plugins-procs -y

# Allow accessibility from the Nagios server to the VM to perform monitoring actions.
sudo cat >> /etc/nagios/nrpe.cfg <<EOF
allowed_hosts=127.0.0.1,192.168.56.10
EOF

# Create a MariaDB user called nagios with password nagiospass and give it permissions for the Nagios check_mysql plugin to work.
sudo mysql -u root -p <<SQL
CREATE USER 'nagios'@'localhost' IDENTIFIED BY 'nagiospass';
GRANT ALL PRIVILEGES ON *.* TO 'nagios'@'localhost';
FLUSH PRIVILEGES;
EXIT;
SQL

# Define the definition of check_command in the configuration file of the NRPE plugin 
cat >> /etc/nagios/nrpe.cfg << EOF
command[check_mysql]=/usr/lib64/nagios/plugins/check_mysql -H 127.0.0.1 -u nagios -p 'nagiospass'
EOF

# Restart NRPE service
sudo systemctl restart nrpe
sudo systemctl enable nrpe