# Flask MySQL Docker Application

A simple Flask web application with MySQL database using Docker Compose.

## Features
- Flask web server running on port 8083
- MySQL database for data persistence
- REST API endpoints for managing messages
- Docker Compose for easy deployment

## API Endpoints
- GET `/`: Welcome message
- GET `/messages`: List all messages
- POST `/messages`: Create a new message
  - Request body: `{"content": "Your message here"}`

## How to Run
1. Make sure Docker and Docker Compose are installed
2. Navigate to this directory
3. Run `docker-compose up --build`
4. Access the application at `http://localhost:8083`

## Testing the API
You can test the API using curl:

```bash
# Get welcome message
curl http://localhost:8083/

# Create a new message
curl -X POST -H "Content-Type: application/json" -d '{"content":"Hello, Docker!"}' http://localhost:8083/messages

# Get all messages
curl http://localhost:8083/messages
```
