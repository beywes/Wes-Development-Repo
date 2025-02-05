# Jenkins Webserver Docker Commands

## Prerequisites
- Docker Desktop installed and running
- Port 8080 and 50000 available on your host machine

## Build and Run Instructions

### 1. Build the Docker Image
```bash
# Navigate to the directory containing the Dockerfile
cd J:/Git Repo/Docker/Docker Files/Ubuntu_Jenkins_Webserver

# Build the image
docker build -t ubuntu-jenkins-webserver:latest .
```

### 2. Verify the Image
```bash
# Check that the image was created successfully
docker images | grep ubuntu-jenkins-webserver
```

### 3. Run the Container

#### Basic Run (Ephemeral Storage)
```bash
# Run with basic configuration
docker run -d \
  --name jenkins-server \
  -p 8080:8080 \
  -p 50000:50000 \
  ubuntu-jenkins-webserver:latest
```

#### Production Run (Recommended)
```bash
# Create a persistent volume for Jenkins data
docker volume create jenkins_home

# Run with persistent storage and additional configurations
docker run -d \
  --name jenkins-server \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -e JAVA_OPTS="-Xmx2048m" \
  -e TZ=America/Chicago \
  --restart unless-stopped \
  ubuntu-jenkins-webserver:latest
```

### 4. Get Initial Admin Password
```bash
# Wait about 30 seconds for Jenkins to start, then get the password
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword
```

### 5. Access Jenkins
1. Open your browser and navigate to: http://localhost:8080
2. Enter the admin password obtained from step 4
3. Follow the Jenkins setup wizard

### 6. Container Management Commands

#### View Container Logs
```bash
# View logs
docker logs jenkins-server

# Follow logs in real-time
docker logs -f jenkins-server
```

#### Stop Container
```bash
docker stop jenkins-server
```

#### Start Container
```bash
docker start jenkins-server
```

#### Remove Container
```bash
# Stop and remove container (data will be preserved if using volume)
docker stop jenkins-server
docker rm jenkins-server
```

#### Remove Image
```bash
# Remove the image (container must be removed first)
docker rmi ubuntu-jenkins-webserver:latest
```

### 7. Backup Jenkins Data
If using persistent storage:
```bash
# Create a backup of the Jenkins volume
docker run --rm \
  -v jenkins_home:/source:ro \
  -v $(pwd):/backup \
  ubuntu \
  tar czf /backup/jenkins_backup_$(date +%Y%m%d).tar.gz -C /source .
```

## Troubleshooting

### Container Won't Start
1. Check if ports are already in use:
```bash
netstat -ano | findstr :8080
netstat -ano | findstr :50000
```

### Memory Issues
1. Adjust Java heap size:
```bash
docker run -d \
  --name jenkins-server \
  -p 8080:8080 \
  -p 50000:50000 \
  -e JAVA_OPTS="-Xmx4096m" \
  ubuntu-jenkins-webserver:latest
```

### Permission Issues
1. Check volume permissions:
```bash
docker exec -it jenkins-server ls -la /var/jenkins_home
```

## Health Check
```bash
# Check container health status
docker inspect --format='{{.State.Health.Status}}' jenkins-server
```
