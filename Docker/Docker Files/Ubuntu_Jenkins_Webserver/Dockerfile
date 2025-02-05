# Use Ubuntu Alpine as base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables
ENV JENKINS_HOME=/var/jenkins_home \
    JENKINS_VERSION=2.426.1 \
    JAVA_OPTS="-Xmx2048m" \
    TZ=UTC

# Install dependencies and clean up in one layer to reduce image size
RUN apt-get update && \
    apt-get install -y \
    openjdk-11-jdk \
    curl \
    git \
    wget \
    unzip \
    python3 \
    fontconfig \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p ${JENKINS_HOME} \
    && useradd -d ${JENKINS_HOME} -u 1000 -m -s /bin/bash jenkins \
    && chown -R jenkins:jenkins ${JENKINS_HOME}

# Switch to jenkins user for security
USER jenkins
WORKDIR ${JENKINS_HOME}

# Download and verify Jenkins
RUN curl -fsSL https://get.jenkins.io/war-stable/${JENKINS_VERSION}/jenkins.war -o /var/jenkins_home/jenkins.war

# Create necessary directories
RUN mkdir -p /var/jenkins_home/www \
    && mkdir -p /var/jenkins_home/init.groovy.d \
    && mkdir -p /var/jenkins_home/jobs/webserver

# Copy web application files
COPY --chown=jenkins:jenkins webapp/ /var/jenkins_home/webapp/

# Copy Jenkins job configuration
COPY --chown=jenkins:jenkins jenkins_jobs/webserver-job.xml /var/jenkins_home/jobs/webserver/config.xml

# Copy startup script
COPY --chown=jenkins:jenkins start-services.sh /var/jenkins_home/start-services.sh
RUN chmod +x /var/jenkins_home/start-services.sh

# Web ports
EXPOSE 8080 8081

# Agent port
EXPOSE 50000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8080/login || exit 1

# Set entry point
ENTRYPOINT ["/var/jenkins_home/start-services.sh"]
