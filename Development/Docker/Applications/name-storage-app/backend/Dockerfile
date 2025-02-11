# Use Python 3.11 slim base image
# slim variant is smaller in size but still contains essential packages
FROM python:3.11-slim

# Set the working directory in the container
# All subsequent commands will be run from this directory
WORKDIR /app

# Copy requirements file first to leverage Docker cache
# This layer will only be rebuilt if requirements.txt changes
COPY requirements.txt .
# Install Python dependencies
# --no-cache-dir reduces the image size by not caching pip packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
# This includes main.py and any other files in the backend directory
COPY . .

# Command to run the FastAPI application using uvicorn server
# --host 0.0.0.0: Listen on all network interfaces
# --port 8000: Run on port 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
