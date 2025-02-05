#!/bin/bash

# Create web directory and copy files
mkdir -p /var/jenkins_home/www
cp -r /var/jenkins_home/webapp/* /var/jenkins_home/www/

# Start Python HTTP server in background
cd /var/jenkins_home/www
nohup python3 -m http.server 8081 > /var/jenkins_home/www/server.log 2>&1 &

# Start Jenkins
exec java -jar /var/jenkins_home/jenkins.war
