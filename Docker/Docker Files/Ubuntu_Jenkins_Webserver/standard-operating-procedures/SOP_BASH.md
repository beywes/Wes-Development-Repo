# Jenkins Webserver Docker SOP (Bash)

## Overview
This SOP provides step-by-step instructions for building, running, and managing a Jenkins webserver with an integrated Python web application using Docker on Unix/Linux systems.

## System Requirements
- Docker Engine installed
- Bash shell
- Available ports: 8080 (Jenkins), 8081 (Web App), 50000 (Jenkins Agent)

## Configuration Details

### Docker Configuration
The setup uses a multi-stage Docker configuration:
1. Base Image: Ubuntu 22.04
2. Java: OpenJDK 11
3. Jenkins: Version 2.426.1
4. Python: Version 3 (for web server)
5. Exposed Ports:
   - 8080: Jenkins UI
   - 8081: Python Web Application
   - 50000: Jenkins Agent

### Web Server Configuration
- Type: Python SimpleHTTPServer
- Port: 8081
- Root Directory: /var/jenkins_home/www
- Source Files: Located in /var/jenkins_home/webapp
- Auto-start: Managed by start-services.sh

## Step-by-Step Procedures

### 1. Building the Docker Image
```bash
# Navigate to Dockerfile directory
cd /path/to/Ubuntu_Jenkins_Webserver

# Build the image
docker build -t ubuntu-jenkins-webserver:latest .

# Verify image creation
docker images | grep ubuntu-jenkins-webserver
```

### 2. Running the Container
```bash
# Create persistent volume (recommended)
docker volume create jenkins_home

# Run container with persistent storage
docker run -d \
  --name jenkins-server \
  -p 8080:8080 \
  -p 8081:8081 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -e JAVA_OPTS="-Xmx2048m" \
  -e TZ=America/Chicago \
  ubuntu-jenkins-webserver:latest

# Verify container is running
docker ps | grep jenkins-server
```

### 3. Initial Setup
```bash
# Get initial admin password
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword

# Access Jenkins UI: http://localhost:8080
# Access Web Application: http://localhost:8081
```

### 4. Container Management
```bash
# View logs
docker logs jenkins-server

# Stop container
docker stop jenkins-server

# Start container
docker start jenkins-server

# Restart container
docker restart jenkins-server
```

### 5. Cleanup Procedures
```bash
# Stop container
docker stop jenkins-server

# Remove container
docker rm jenkins-server

# Remove image
docker rmi ubuntu-jenkins-webserver:latest

# Remove volume (optional)
docker volume rm jenkins_home
```

## Automated Deployment

An automated deployment script (`deploy-jenkins.sh`) is provided to streamline the build and deployment process.

### Script Features
- Automatic port availability checking
- Cleanup of existing resources
- Image building and container deployment
- Service health checking
- Automatic retrieval of Jenkins admin password
- Colored output for better readability
- Error handling and status reporting

### Using the Script
```bash
# Make the script executable
chmod +x deploy-jenkins.sh

# Run the script
./deploy-jenkins.sh
```

The script will:
1. Check if required ports (8080, 8081, 50000) are available
2. Clean up any existing container and volume
3. Build the Docker image
4. Create and configure the Jenkins volume
5. Start the container
6. Wait for both Jenkins and the web application to become available
7. Display the Jenkins initial admin password
8. Provide URLs for accessing the services

### Script Location
The deployment script is located at:
```
./deploy-jenkins.sh
```

### Error Handling
The script includes comprehensive error handling:
- Port conflict detection
- Build failure handling
- Container startup verification
- Service availability checking

If any step fails, the script will:
1. Display an error message
2. Clean up any created resources
3. Exit with a non-zero status code

### Monitoring Progress
The script provides detailed progress information:
- Build status updates
- Service startup progress
- Health check results
- Final deployment status

### Example Output
```bash
Starting Jenkins Webserver Deployment...
Cleaning up existing resources...
Building Docker image...
Creating Jenkins volume...
Starting container...
Waiting for Jenkins to start...
Waiting for Web Application to start...
Retrieving Jenkins initial admin password...
Deployment complete!
Jenkins UI: http://localhost:8080
Web Application: http://localhost:8081
Jenkins Agent Port: 50000
```

## Troubleshooting Guide

### 1. Jenkins UI Not Accessible
```bash
# Check container status
docker ps | grep jenkins-server

# View Jenkins logs
docker logs jenkins-server

# Verify port mapping
docker port jenkins-server

# Check process in container
docker exec jenkins-server ps aux | grep java
```

### 2. Web Application Not Accessible
```bash
# Check Python server process
docker exec jenkins-server ps aux | grep python

# View web server logs
docker exec jenkins-server cat /var/jenkins_home/www/server.log

# Verify web files exist
docker exec jenkins-server ls -la /var/jenkins_home/www/

# Manually start web server if needed
docker exec jenkins-server bash -c "cd /var/jenkins_home/www && python3 -m http.server 8081 &"
```

### 3. Volume Permission Issues
```bash
# Check volume permissions
docker exec jenkins-server ls -la /var/jenkins_home

# Fix permissions if needed
docker exec jenkins-server chown -R jenkins:jenkins /var/jenkins_home
```

### 4. Network Issues
```bash
# Check container network
docker network inspect bridge

# Test internal web server
docker exec jenkins-server curl http://localhost:8081

# View all port bindings
docker port jenkins-server
```

### 5. Resource Issues
```bash
# Check container resource usage
docker stats jenkins-server

# View container details
docker inspect jenkins-server

# Increase memory if needed (requires container restart)
docker update --memory 4g jenkins-server
```

## Backup and Recovery

### Create Backup
```bash
# Create backup directory
mkdir -p ~/jenkins-backups

# Backup Jenkins data
docker run --rm \
  -v jenkins_home:/source:ro \
  -v ~/jenkins-backups:/backup \
  ubuntu \
  tar czf /backup/jenkins_backup_$(date +%Y%m%d).tar.gz -C /source .
```

### Restore from Backup
```bash
# Stop container
docker stop jenkins-server

# Remove old volume
docker volume rm jenkins_home

# Create new volume
docker volume create jenkins_home

# Restore from backup
docker run --rm \
  -v jenkins_home:/restore \
  -v ~/jenkins-backups:/backup \
  ubuntu \
  bash -c "cd /restore && tar xzf /backup/jenkins_backup_YYYYMMDD.tar.gz"

# Start container
docker start jenkins-server
```
