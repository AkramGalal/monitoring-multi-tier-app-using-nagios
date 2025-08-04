#! /usr/bin/bash

sudo -i 

# Update OS with latest patches
yum update -y

# Set Repository
yum install epel-release -y

# Install Dependencies
dnf -y install java-11-openjdk java-11-openjdk-devel
dnf install git maven wget -y

# Change dir to /tmp
cd /tmp/

# Download & Tomcat Package
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
tar xzvf apache-tomcat-9.0.75.tar.gz

# Add tomcat user
useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat

# Copy data to tomcat home dir
cp -r /tmp/apache-tomcat-9.0.75/* /usr/local/tomcat/

# Make tomcat user owner of tomcat home dir
chown -R tomcat.tomcat /usr/local/tomcat

# Create tomcat service file
cat > /etc/systemd/system/tomcat.service << EOF

[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target

EOF

# Reload systemd files
systemctl daemon-reload

# Start & Enable service
systemctl start tomcat
systemctl enable tomcat

# CODE BUILD & DEPLOY (app01)
# Download Source code
git clone -b main https://github.com/hkhcoder/vprofile-project.git

# Update configuration
cd vprofile-project


# Build code
# Run below command inside the repository (vprofile-project)
mvn install

# Deploy artifact
systemctl stop tomcat
rm -rf /usr/local/tomcat/webapps/ROOT*
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
systemctl start tomcat
chown tomcat.tomcat /usr/local/tomcat/webapps -R
systemctl restart tomcat

# Remove Java 17 for incompatibility  
systemctl stop tomcat
dnf remove java-17-openjdk* -y
systemctl restart tomcat
