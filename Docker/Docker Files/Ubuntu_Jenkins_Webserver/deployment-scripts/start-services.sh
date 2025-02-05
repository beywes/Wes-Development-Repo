#!/bin/bash

# Function to check if a port is available
check_port() {
    local port=$1
    if ! nc -z localhost $port >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to wait for port to become available
wait_for_port() {
    local port=$1
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if check_port $port; then
            return 0
        fi
        echo "Waiting for port $port to become available (attempt $attempt/$max_attempts)..."
        sleep 5
        attempt=$((attempt + 1))
    done
    return 1
}

echo "Starting Jenkins deployment..."

# Create web directory and copy files
mkdir -p /var/jenkins_home/www
cp -r /var/jenkins_home/webapp/* /var/jenkins_home/www/

# Start Python HTTP server in background
cd /var/jenkins_home/www
echo "Starting Python web server..."
python3 -m http.server 8081 > /var/jenkins_home/www/server.log 2>&1 &
PYTHON_PID=$!

# Wait for Python server to start
wait_for_port 8081
if [ $? -ne 0 ]; then
    echo "Failed to start Python web server"
    exit 1
fi

echo "Python web server started successfully"

# Start Jenkins
echo "Starting Jenkins..."
cd /var/jenkins_home
exec java -jar jenkins.war --httpPort=8080 --argumentsRealm.passwd.admin=admin123! --argumentsRealm.roles.admin=admin
