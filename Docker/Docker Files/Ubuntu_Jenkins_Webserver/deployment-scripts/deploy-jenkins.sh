#!/bin/bash

echo "Starting Jenkins Webserver Deployment..."

# Function to check if a port is in use
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        return 0
    else
        return 1
    fi
}

# Function to wait for service availability
wait_for_service() {
    local url=$1
    local max_attempts=30
    local attempt=1
    
    echo "Waiting for service at $url..."
    while ! curl -s -f "$url" > /dev/null; do
        if [ $attempt -eq $max_attempts ]; then
            echo "Service not available after $max_attempts attempts"
            return 1
        fi
        echo "Attempt $attempt: Service not yet available, waiting..."
        sleep 10
        ((attempt++))
    done
    echo "Service is available!"
    return 0
}

# Check if required ports are available
for port in 8080 8081 50000; do
    if check_port $port; then
        echo "Error: Port $port is already in use"
        exit 1
    fi
done

# Clean up any existing container and volume
echo "Cleaning up existing resources..."
docker stop jenkins-server 2>/dev/null
docker rm jenkins-server 2>/dev/null
docker volume rm jenkins_home 2>/dev/null

# Build the image
echo "Building Docker image..."
docker build -t ubuntu-jenkins-webserver:latest . || {
    echo "Error: Docker build failed"
    exit 1
}

# Create volume
echo "Creating Jenkins volume..."
docker volume create jenkins_home || {
    echo "Error: Failed to create volume"
    exit 1
}

# Run container
echo "Starting container..."
docker run -d \
    --name jenkins-server \
    -p 8080:8080 \
    -p 8081:8081 \
    -p 50000:50000 \
    -v jenkins_home:/var/jenkins_home \
    -e JAVA_OPTS="-Xmx2048m" \
    ubuntu-jenkins-webserver:latest || {
    echo "Error: Failed to start container"
    exit 1
}

# Wait for services to start
echo "Waiting for Jenkins to start..."
wait_for_service "http://localhost:8080" || {
    echo "Error: Jenkins failed to start"
    exit 1
}

echo "Waiting for Web Application to start..."
wait_for_service "http://localhost:8081" || {
    echo "Error: Web Application failed to start"
    exit 1
}

# Get initial admin password
echo "Retrieving Jenkins initial admin password..."
sleep 10
JENKINS_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword)
echo "Jenkins initial admin password: $JENKINS_PASSWORD"

echo "Deployment complete!"
echo "Jenkins UI: http://localhost:8080"
echo "Web Application: http://localhost:8081"
echo "Jenkins Agent Port: 50000"
