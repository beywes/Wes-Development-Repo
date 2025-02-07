# Deploy.ps1 - PowerShell script to auto deploy the Resume Builder app

Write-Host "Starting deployment..."

# Navigate to the script's directory (assumes the script is in the project root)
Set-Location -Path $PSScriptRoot

# Function to test if Python is actually installed (not just the Store alias)
function Test-PythonInstallation {
    param (
        [string]$Command
    )
    
    try {
        $version = & $Command --version 2>&1
        return -not $version.ToString().Contains("Microsoft Store")
    }
    catch {
        return $false
    }
}

# Function to get the latest Python version and download URL
function Get-LatestPythonInfo {
    Write-Host "Detecting latest Python version..."
    
    try {
        # Get the Python downloads page
        $downloadPage = Invoke-WebRequest -Uri "https://www.python.org/downloads/" -UseBasicParsing
        
        # Extract the latest Python 3 version from the page
        $latestVersionPattern = "Latest Python 3 Release - Python (3\.\d+\.\d+)"
        $versionMatch = [regex]::Match($downloadPage.Content, $latestVersionPattern)
        
        if (-not $versionMatch.Success) {
            throw "Could not detect latest Python version"
        }
        
        $latestVersion = $versionMatch.Groups[1].Value
        Write-Host "Latest Python version detected: $latestVersion"
        
        # Construct the download URL for Windows 64-bit installer
        $downloadUrl = "https://www.python.org/ftp/python/$latestVersion/python-$latestVersion-amd64.exe"
        
        return @{
            Version = $latestVersion
            DownloadUrl = $downloadUrl
        }
    }
    catch {
        Write-Host "Failed to detect latest Python version: $_"
        Write-Host "Falling back to default version 3.11.8..."
        return @{
            Version = "3.11.8"
            DownloadUrl = "https://www.python.org/ftp/python/3.11.8/python-3.11.8-amd64.exe"
        }
    }
}

# Function to download and install Python
function Install-Python {
    Write-Host "Preparing to install Python..."
    
    # Get latest Python version info
    $pythonInfo = Get-LatestPythonInfo
    
    # Create a temporary directory for the download
    $tempDir = Join-Path $env:TEMP "PythonInstall"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    
    # Download Python installer
    $installerPath = Join-Path $tempDir "python_installer.exe"
    Write-Host "Downloading Python $($pythonInfo.Version) installer..."
    
    try {
        Invoke-WebRequest -Uri $pythonInfo.DownloadUrl -OutFile $installerPath
    }
    catch {
        Write-Host "Failed to download Python installer: $_"
        Write-Host "Please download and install Python manually from https://www.python.org/downloads/"
        exit 1
    }
    
    Write-Host "Installing Python $($pythonInfo.Version)..."
    Write-Host "This may take a few minutes. Please wait..."
    
    # Install Python with required options
    $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_test=0" -Wait -PassThru
    
    if ($installProcess.ExitCode -ne 0) {
        Write-Host "Python installation failed. Please install Python manually from https://www.python.org/downloads/"
        exit 1
    }
    
    Write-Host "Python $($pythonInfo.Version) installed successfully."
    
    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    
    # Clean up
    Remove-Item -Path $tempDir -Recurse -Force
}

# Function to get pip user scripts directory
function Get-PipScriptsPath {
    $userBase = & $pythonCommand -m site --user-base
    $pythonVersion = & $pythonCommand -c "import sys; print(f'{sys.version_info.major}{sys.version_info.minor}')"
    return Join-Path $userBase "Python$pythonVersion\Scripts"
}

# Check Python installation
$pythonCommand = $null
$commands = @("python", "python3", "py")
foreach ($cmd in $commands) {
    if (Get-Command $cmd -ErrorAction SilentlyContinue) {
        if (Test-PythonInstallation $cmd) {
            $pythonCommand = $cmd
            break
        }
    }
}

# If Python is not installed, install it
if (-not $pythonCommand) {
    Write-Host "Python is not installed. Installing Python..."
    Install-Python
    
    # Recheck Python installation
    foreach ($cmd in $commands) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            if (Test-PythonInstallation $cmd) {
                $pythonCommand = $cmd
                break
            }
        }
    }
    
    if (-not $pythonCommand) {
        Write-Host "Failed to verify Python installation. Please restart your computer and try again."
        exit 1
    }
}

Write-Host "Using Python command: $pythonCommand"

# Check if pip is available
$pipResult = & $pythonCommand -m pip --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: pip is not available!"
    Write-Host "Please ensure Python was installed correctly with pip."
    exit 1
}

# Ensure flake8 is installed
$pipScriptsPath = Get-PipScriptsPath
$flake8Path = Join-Path $pipScriptsPath "flake8.exe"

if (-not (Test-Path $flake8Path)) {
    Write-Host "flake8 not found. Installing flake8..."
    & $pythonCommand -m pip install flake8
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install flake8. Please try running 'python -m pip install flake8' manually."
        exit $LASTEXITCODE
    }
    Write-Host "flake8 installed successfully."
}

# Step 1: Run flake8 linting
Write-Host "Running flake8 linting..."
& $pythonCommand -m flake8 .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Linting failed! Please fix the issues before deployment."
    exit $LASTEXITCODE
}
Write-Host "Linting passed."

# Step 2: Check Docker status
Write-Host "Checking Docker status..."
try {
    $dockerInfo = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker is not running. Please start Docker and try again."
        exit 1
    }
} catch {
    Write-Host "Docker is not installed or not running. Please install Docker Desktop and try again."
    exit 1
}

# Step 3: Build Docker image
Write-Host "Building Docker image..."
docker build -t resume_builder_app .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!"
    exit $LASTEXITCODE
}
Write-Host "Docker image built successfully."

# Step 4: Check and remove existing container
$existingContainer = docker ps -a -q -f name=resume_builder_app
if ($existingContainer) {
    Write-Host "Stopping existing resume_builder_app container..."
    docker stop resume_builder_app
    Write-Host "Removing existing resume_builder_app container..."
    docker rm resume_builder_app
}

# Step 5: Run the Docker container
Write-Host "Starting Docker container..."
docker run -d --name resume_builder_app -p 5000:5000 resume_builder_app
if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker container failed to start!"
    exit $LASTEXITCODE
}

# Step 6: Verify container is running
$runningContainer = docker ps -q -f name=resume_builder_app
if (-not $runningContainer) {
    Write-Host "Container failed to start. Checking container logs:"
    docker logs resume_builder_app
    exit 1
}

Write-Host "Deployment completed successfully!"
Write-Host "The Resume Builder App is now available at http://localhost:5000"
Write-Host "Container logs:"
docker logs resume_builder_app
