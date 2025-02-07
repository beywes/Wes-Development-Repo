# Resume Builder Application

A Flask-based web application for creating and managing professional resumes. This application provides a simple interface for users to input their information and generate well-formatted resumes.

## Features

- User-friendly web interface
- Support for personal information, work experience, education, and skills
- Responsive design
- Docker containerization
- Automated deployment with PowerShell
- Code quality checks with flake8

## Prerequisites

- Python 3.8 or higher
- Docker Desktop
- PowerShell 5.1 or higher

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd resume_builder_app
```

2. Run the deployment script:
```powershell
.\deploy.ps1
```

The script will:
- Verify Python installation
- Install required dependencies
- Run code quality checks
- Build and deploy the Docker container

## Development Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: .\venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Run the application locally:
```bash
python app.py
```

## Docker Deployment

The application is containerized using Docker for consistent deployment:

```bash
docker build -t resume_builder_app .
docker run -d -p 5000:5000 --name resume_builder_app resume_builder_app
```

## Project Structure

```
resume_builder_app/
├── app.py              # Main Flask application
├── requirements.txt    # Python dependencies
├── Dockerfile         # Docker configuration
├── deploy.ps1         # Deployment script
├── .flake8           # Linting configuration
├── templates/        # HTML templates
└── ansible/          # Deployment automation
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
