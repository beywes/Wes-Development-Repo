# Jenkins Webserver Docker Image

This Docker image provides a Jenkins server running on Ubuntu 22.04 with the following features:

## Features
- Based on Ubuntu 22.04
- Jenkins version 2.426.1 (LTS)
- OpenJDK 11
- Built-in health checks
- Security optimizations
- Proper user permissions
- Volume support for persistent data

## Ports
- 8080: Jenkins web interface
- 50000: Jenkins agent connection port

## Environment Variables
- `JENKINS_HOME`: /var/jenkins_home
- `JAVA_OPTS`: -Xmx2048m (Configurable Java heap size)
- `TZ`: UTC (Configurable timezone)

## Usage

### Basic Run
```bash
docker build -t jenkins-ubuntu .
docker run -d -p 8080:8080 -p 50000:50000 jenkins-ubuntu
```

### With Persistent Volume
```bash
docker run -d \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins-ubuntu
```

### With Custom Java Options
```bash
docker run -d \
  -p 8080:8080 \
  -p 50000:50000 \
  -e JAVA_OPTS="-Xmx4096m" \
  jenkins-ubuntu
```

## Initial Setup
1. Access Jenkins at http://localhost:8080
2. Get the initial admin password from the logs:
   ```bash
   docker logs <container_id>
   ```
3. Follow the setup wizard to complete installation

## Security Notes
- Runs as non-root user 'jenkins'
- Uses HTTPS for package downloads
- Regular security updates included
- Minimal base image to reduce attack surface
