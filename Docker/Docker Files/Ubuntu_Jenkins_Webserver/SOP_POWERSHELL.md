# Jenkins Webserver Docker SOP (PowerShell)

## Overview
This SOP provides step-by-step instructions for building, running, and managing a Jenkins webserver with an integrated Python web application using Docker on Windows systems with PowerShell.

## System Requirements
- Docker Desktop for Windows installed and running
- PowerShell
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
```powershell
# Navigate to Dockerfile directory
Set-Location -Path "C:\path\to\Ubuntu_Jenkins_Webserver"

# Build the image
docker build -t ubuntu-jenkins-webserver:latest .

# Verify image creation
docker images | Where-Object { $_ -match "ubuntu-jenkins-webserver" }
```

### 2. Running the Container
```powershell
# Create persistent volume (recommended)
docker volume create jenkins_home

# Run container with persistent storage
docker run -d `
  --name jenkins-server `
  -p 8080:8080 `
  -p 8081:8081 `
  -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  -e JAVA_OPTS="-Xmx2048m" `
  -e TZ=America/Chicago `
  ubuntu-jenkins-webserver:latest

# Verify container is running
docker ps | Select-String "jenkins-server"
```

### 3. Initial Setup
```powershell
# Get initial admin password
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword

# Access Jenkins UI: http://localhost:8080
# Access Web Application: http://localhost:8081
```

### 4. Container Management
```powershell
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
```powershell
# Stop container
docker stop jenkins-server

# Remove container
docker rm jenkins-server

# Remove image
docker rmi ubuntu-jenkins-webserver:latest

# Remove volume (optional)
docker volume rm jenkins_home
```

## Troubleshooting Guide

### 1. Jenkins UI Not Accessible
```powershell
# Check container status
docker ps | Select-String "jenkins-server"

# View Jenkins logs
docker logs jenkins-server

# Check port usage
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue

# Test connection
Test-NetConnection -ComputerName localhost -Port 8080
```

### 2. Web Application Not Accessible
```powershell
# Check Python server process
docker exec jenkins-server ps aux | Select-String "python"

# View web server logs
docker exec jenkins-server cat /var/jenkins_home/www/server.log

# Verify web files exist
docker exec jenkins-server ls -la /var/jenkins_home/www/

# Test internal connection
docker exec jenkins-server curl http://localhost:8081

# Check port usage
Get-NetTCPConnection -LocalPort 8081 -ErrorAction SilentlyContinue

# Restart Python server if needed
docker exec jenkins-server bash -c "pkill python3; cd /var/jenkins_home/www && python3 -m http.server 8081 &"
```

### 3. Volume Permission Issues
```powershell
# Check volume permissions
docker exec jenkins-server ls -la /var/jenkins_home

# Fix permissions if needed
docker exec jenkins-server chown -R jenkins:jenkins /var/jenkins_home

# Verify volume mount
docker inspect jenkins-server | Select-String "Mounts" -Context 10
```

### 4. Network Issues
```powershell
# Check Docker network
docker network inspect bridge

# View container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jenkins-server

# Test all required ports
$ports = 8080, 8081, 50000
foreach ($port in $ports) {
    Write-Host "Testing port $port"
    Test-NetConnection -ComputerName localhost -Port $port
}
```

### 5. Resource Issues
```powershell
# Check container resource usage
docker stats jenkins-server

# View detailed container info
docker inspect jenkins-server

# Update container resources
docker update --memory 4g jenkins-server
```

## Backup and Recovery

### Create Backup
```powershell
# Create backup directory
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\jenkins-backups"

# Backup Jenkins data
$backupDate = Get-Date -Format "yyyyMMdd"
docker run --rm `
  -v jenkins_home:/source:ro `
  -v "$($env:USERPROFILE -replace '\\', '/')/jenkins-backups:/backup" `
  ubuntu `
  tar czf "/backup/jenkins_backup_$backupDate.tar.gz" -C /source .
```

### Restore from Backup
```powershell
# Stop container
docker stop jenkins-server

# Remove old volume
docker volume rm jenkins_home

# Create new volume
docker volume create jenkins_home

# Restore from backup (replace YYYYMMDD with actual date)
docker run --rm `
  -v jenkins_home:/restore `
  -v "$($env:USERPROFILE -replace '\\', '/')/jenkins-backups:/backup" `
  ubuntu `
  bash -c "cd /restore && tar xzf /backup/jenkins_backup_YYYYMMDD.tar.gz"

# Start container
docker start jenkins-server
```

### Docker System Maintenance
```powershell
# View system info
docker system info

# Check disk usage
docker system df

# Clean up unused resources
docker system prune -a --volumes

# List all Docker processes
Get-Process *docker* | Format-Table -AutoSize
```
