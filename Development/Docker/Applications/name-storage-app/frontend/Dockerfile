# Use the official Nginx Alpine image as base
# Alpine-based images are lightweight and security-focused
FROM nginx:alpine

# Copy the static HTML file to Nginx's default serving directory
# This is where Nginx will look for files to serve
COPY index.html /usr/share/nginx/html/

# Copy custom Nginx configuration
# This configuration file contains server settings and routing rules
COPY nginx.conf /etc/nginx/conf.d/default.conf
