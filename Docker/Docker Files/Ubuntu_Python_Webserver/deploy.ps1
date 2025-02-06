# Stop and remove any existing container with the same name
docker stop python-web-server 2>$null
docker rm python-web-server 2>$null

# Build the Docker image
Write-Host "Building Docker image..." -ForegroundColor Green
docker build -t python-web-server .

# Run the container
Write-Host "Starting container..." -ForegroundColor Green
docker run -d --name python-web-server -p 8082:8082 python-web-server

Write-Host "Web server is running!" -ForegroundColor Green
Write-Host "Access the application at: http://localhost:8082" -ForegroundColor Yellow
