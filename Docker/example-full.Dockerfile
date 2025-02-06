# Syntax parser directive - tells Docker which syntax version to use
# syntax=docker/dockerfile:1.4

# ARG can be used before FROM for base image configuration
ARG UBUNTU_VERSION=22.04

# FROM - Specifies the base image (can have multiple FROM statements for multi-stage builds)
FROM ubuntu:${UBUNTU_VERSION} AS build-stage
FROM python:3.11-slim AS python-base
FROM node:18-alpine AS node-base

# LABEL - Adds metadata to the image
LABEL maintainer="example@company.com"
LABEL version="1.0"
LABEL description="Example Dockerfile with all possible instructions"

# ARG - Defines build-time variables (only available during build)
ARG BUILD_VERSION
ARG ENVIRONMENT=production

# ENV - Sets environment variables (persists in the final image)
ENV APP_HOME=/app
ENV PATH="${APP_HOME}/bin:${PATH}"
ENV NODE_ENV=production

# WORKDIR - Sets the working directory for subsequent instructions
WORKDIR ${APP_HOME}

# COPY - Copies files from host to container
# Format: COPY [--chown=user:group] [--chmod=permissions] src dest
COPY --chown=node:node package*.json ./
COPY --chmod=755 ./scripts/entrypoint.sh ./
COPY . .

# ADD - Similar to COPY but can also handle URLs and automatically extract archives
# Format: ADD [--chown=user:group] [--chmod=permissions] src dest
ADD https://example.com/big.tar.xz /usr/src/
ADD --chmod=755 program.tar.gz /install/

# RUN - Executes commands during build time
# Shell form
RUN apt-get update && \
    apt-get install -y \
        curl \
        nginx \
        postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Exec form
RUN ["pip", "install", "-r", "requirements.txt"]
RUN ["npm", "ci", "--only=production"]

# USER - Sets the user for subsequent instructions
USER node
USER 1000:1000

# EXPOSE - Documents which ports the container listens on
EXPOSE 80/tcp
EXPOSE 443 8080

# VOLUME - Creates a mount point for external volumes
VOLUME ["/data"]
VOLUME /logs /tmp

# ENTRYPOINT - Configures container to run as executable
# Shell form
ENTRYPOINT ./entrypoint.sh

# Exec form (preferred)
ENTRYPOINT ["python", "app.py"]

# CMD - Provides defaults for executing container (can be overridden)
# As default parameters to ENTRYPOINT
CMD ["--port", "8080"]

# As standalone command (exec form)
CMD ["npm", "start"]

# Shell form
CMD echo "Container started"

# HEALTHCHECK - Tells Docker how to test if container is working
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# SHELL - Changes the default shell used for Shell form commands
SHELL ["/bin/bash", "-c"]

# ONBUILD - Adds triggers to be executed when image is used as base image
ONBUILD COPY . /app/src
ONBUILD RUN pip install -r requirements.txt

# STOPSIGNAL - Sets system call signal that will be sent to container to exit
STOPSIGNAL SIGTERM

# Example of multi-stage build to create smaller final image
FROM node:18-alpine AS builder
WORKDIR /build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /build/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
