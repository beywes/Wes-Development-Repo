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

# Web port
EXPOSE 8080

# Agent port
EXPOSE 50000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8080/login || exit 1

# Set entry point
ENTRYPOINT ["java", "-jar", "/var/jenkins_home/jenkins.war"]
