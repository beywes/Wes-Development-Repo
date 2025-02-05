# Jenkins Webserver Deployment Script
$ErrorActionPreference = "Stop"

# Get the parent directory (root of the project)
$projectRoot = Split-Path -Parent $PSScriptRoot

Write-Host "Starting Jenkins Webserver Deployment..." -ForegroundColor Green

# Function to check if a port is in use
function Test-PortInUse {
    param($Port)
    $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return $null -ne $connection
}

# Function to wait for service availability
function Wait-ForService {
    param(
        [string]$Url,
        [string]$ServiceName = "Service",
        [int]$MaxAttempts = 60,
        [int]$DelaySeconds = 10
    )
    
    Write-Host "Waiting for $ServiceName at $Url..." -ForegroundColor Yellow
    $attempt = 1
    
    while ($attempt -le $MaxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Host "$ServiceName is available!" -ForegroundColor Green
                return $true
            }
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 403) {
                # Jenkins returns 403 when it's running but requires authentication
                Write-Host "$ServiceName is available!" -ForegroundColor Green
                return $true
            }
            Write-Host "Attempt $attempt/$MaxAttempts`: $ServiceName not yet available, waiting..." -ForegroundColor Yellow
            
            # Check if container is still running
            $containerStatus = docker ps --filter "name=jenkins-server" --format "{{.Status}}"
            if (-not $containerStatus) {
                Write-Host "Error: Container stopped unexpectedly" -ForegroundColor Red
                Write-Host "Container logs:" -ForegroundColor Yellow
                docker logs jenkins-server
                return $false
            }
            
            Start-Sleep -Seconds $DelaySeconds
            $attempt++
        }
    }
    
    Write-Host "$ServiceName not available after $MaxAttempts attempts" -ForegroundColor Red
    Write-Host "Container logs:" -ForegroundColor Yellow
    docker logs jenkins-server
    return $false
}

# Function to clean up resources
function Remove-DockerResources {
    param(
        [string]$ContainerName,
        [string]$VolumeName
    )
    
    Write-Host "Cleaning up resources..." -ForegroundColor Yellow
    
    # Stop and remove container
    $container = docker ps -a --filter "name=$ContainerName" --format "{{.Names}}"
    if ($container) {
        Write-Host "Stopping container $ContainerName..." -ForegroundColor Yellow
        docker stop $ContainerName 2>&1 | Out-Null
        Write-Host "Removing container $ContainerName..." -ForegroundColor Yellow
        docker rm $ContainerName 2>&1 | Out-Null
    }
    
    # Remove volume
    $volume = docker volume ls --filter "name=$VolumeName" --format "{{.Name}}"
    if ($volume) {
        Write-Host "Removing volume $VolumeName..." -ForegroundColor Yellow
        docker volume rm $VolumeName 2>&1 | Out-Null
    }
}

# Check required files exist
$requiredFiles = @(
    Join-Path $projectRoot "Dockerfile"
    Join-Path $projectRoot "deployment-scripts\start-services.sh"
    Join-Path $projectRoot "webapp\config\jenkins.yaml"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "Error: Required file not found: $file" -ForegroundColor Red
        exit 1
    }
}

# Check if required ports are available
$requiredPorts = @(8080, 8081, 50000)
foreach ($port in $requiredPorts) {
    if (Test-PortInUse -Port $port) {
        Write-Host "Error: Port $port is already in use" -ForegroundColor Red
        exit 1
    }
}

# Clean up any existing resources
Remove-DockerResources -ContainerName "jenkins-server" -VolumeName "jenkins_home"

# Build the image
Write-Host "Building Docker image..." -ForegroundColor Yellow
try {
    # Change to project root directory where Dockerfile is located
    Set-Location -LiteralPath $projectRoot
    
    # Run Docker build with progress display
    $process = Start-Process -FilePath "docker" -ArgumentList "build --no-cache -t ubuntu-jenkins-webserver:latest ." -NoNewWindow -Wait -PassThru
    
    if ($process.ExitCode -ne 0) {
        throw "Docker build failed with exit code $($process.ExitCode)"
    }
    
    Write-Host "Docker image built successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Error: Docker build failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Set-Location -LiteralPath $PSScriptRoot
    exit 1
}

# Create volume
Write-Host "Creating Jenkins volume..." -ForegroundColor Yellow
try {
    docker volume create jenkins_home
}
catch {
    Write-Host "Error: Failed to create volume" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Run container
Write-Host "Starting container..." -ForegroundColor Yellow
try {
    docker run -d `
        --name jenkins-server `
        -p 8080:8080 `
        -p 8081:8081 `
        -p 50000:50000 `
        -v jenkins_home:/var/jenkins_home `
        -e JAVA_OPTS="-Xmx2048m" `
        -e JENKINS_ADMIN_ID=admin `
        -e JENKINS_ADMIN_PASSWORD=admin123! `
        ubuntu-jenkins-webserver:latest
}
catch {
    Write-Host "Error: Failed to start container" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Remove-DockerResources -ContainerName "jenkins-server" -VolumeName "jenkins_home"
    exit 1
}

# Wait for Jenkins to start (with longer timeout and better status checking)
Write-Host "`nWaiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 10 # Give the container a moment to start

# Check container status
$containerStatus = docker ps --filter "name=jenkins-server" --format "{{.Status}}"
if (-not $containerStatus) {
    Write-Host "Error: Container failed to start" -ForegroundColor Red
    Write-Host "Container logs:" -ForegroundColor Yellow
    docker logs jenkins-server
    Remove-DockerResources -ContainerName "jenkins-server" -VolumeName "jenkins_home"
    exit 1
}

# Wait for Jenkins with longer timeout
if (-not (Wait-ForService -Url "http://localhost:8080" -ServiceName "Jenkins" -MaxAttempts 60 -DelaySeconds 10)) {
    Write-Host "Error: Jenkins failed to start properly" -ForegroundColor Red
    Remove-DockerResources -ContainerName "jenkins-server" -VolumeName "jenkins_home"
    exit 1
}

# Wait for Web Application
if (-not (Wait-ForService -Url "http://localhost:8081" -ServiceName "Web Application" -MaxAttempts 30 -DelaySeconds 5)) {
    Write-Host "Error: Web Application failed to start" -ForegroundColor Red
    Remove-DockerResources -ContainerName "jenkins-server" -VolumeName "jenkins_home"
    exit 1
}

Write-Host "`nDeployment complete!" -ForegroundColor Green
Write-Host "Jenkins UI: http://localhost:8080" -ForegroundColor Cyan
Write-Host "Web Application: http://localhost:8081" -ForegroundColor Cyan
Write-Host "Jenkins Agent Port: 50000" -ForegroundColor Cyan
Write-Host "`nJenkins Credentials:" -ForegroundColor Green
Write-Host "Username: admin" -ForegroundColor Yellow
Write-Host "Password: admin123!" -ForegroundColor Yellow

# Return to original directory
Set-Location -LiteralPath $PSScriptRoot
