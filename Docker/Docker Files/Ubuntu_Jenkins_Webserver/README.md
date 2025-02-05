# Jenkins Webserver Docker Setup

This repository contains a Docker-based Jenkins setup with an integrated Python web application.

## Directory Structure

```
Ubuntu_Jenkins_Webserver/
├── deployment-scripts/           # Deployment and automation scripts
│   ├── deploy-jenkins.ps1       # PowerShell deployment script
│   ├── deploy-jenkins.sh        # Bash deployment script
│   └── start-services.sh        # Container startup script
│
├── webapp/                      # Web application files
│   ├── config/                  # Configuration files
│   │   └── jenkins.yaml         # Jenkins Configuration as Code
│   ├── index.html              # Main web page
│   └── test.html               # Test web page
│
├── standard-operating-procedures/ # Documentation
│   ├── SOP_BASH.md             # Unix/Linux deployment guide
│   └── SOP_POWERSHELL.md       # Windows deployment guide
│
├── Dockerfile                   # Docker image definition
└── README.md                    # This file
```

## Quick Start

### Windows (PowerShell)
```powershell
cd deployment-scripts
.\deploy-jenkins.ps1
```

### Unix/Linux (Bash)
```bash
cd deployment-scripts
chmod +x deploy-jenkins.sh
./deploy-jenkins.sh
```

## Access Information

- Jenkins UI: http://localhost:8080
  - Username: admin
  - Password: admin123!
- Web Application: http://localhost:8081
- Jenkins Agent Port: 50000

## Documentation

Detailed setup and usage instructions can be found in the `standard-operating-procedures` directory:
- `SOP_BASH.md` - Unix/Linux deployment guide
- `SOP_POWERSHELL.md` - Windows deployment guide
