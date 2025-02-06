# Pet Voting Application - A Complete Guide to Microservices with Docker

This guide will walk you through building a microservices-based pet voting application using Docker, Python, Node.js, Redis, and PostgreSQL. Perfect for beginners learning about microservices, Docker containerization, and full-stack development.

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technologies Used](#technologies-used)
3. [Application Architecture](#application-architecture)
4. [Step-by-Step Guide](#step-by-step-guide)
5. [Running the Application](#running-the-application)
6. [How Everything Works Together](#how-everything-works-together)
7. [Learning Outcomes](#learning-outcomes)

## Project Overview

This project is a simple voting application where users can:
- Vote for their favorite pet (dogs, cats, or lizards)
- See real-time voting results
- Experience how different services work together in a microservices architecture

## Technologies Used

### Frontend
- **Voting App**: Python/Flask (Port 8084)
  - Simple web interface for voting
  - Communicates with Redis for vote storage

- **Result App**: Node.js/Express (Port 8085)
  - Real-time results display
  - Uses Socket.IO for live updates
  - Fetches data from PostgreSQL

### Backend
- **Redis**: In-memory data store
  - Temporary storage for votes
  - Queue system for vote processing

- **PostgreSQL**: Relational database
  - Permanent storage for votes
  - Stores vote counts and statistics

### Worker Service
- **Python Worker**:
  - Processes votes from Redis
  - Updates PostgreSQL database

### Infrastructure
- **Docker**: Container platform
- **Docker Compose**: Multi-container orchestration

## Application Architecture

```
[User Browser]
       ↓
┌─────────────┐    ┌─────────────┐
│  Voting App │    │ Result App  │
│   (Python)  │    │  (Node.js)  │
└─────────────┘    └─────────────┘
       ↓                  ↑
       ↓                  ↑
┌─────────────┐    ┌─────────────┐
│    Redis    │←───│   Worker    │───→┌─────────────┐
│  (Queue)    │    │   (Python)  │    │ PostgreSQL  │
└─────────────┘    └─────────────┘    └─────────────┘
```

## Step-by-Step Guide

### 1. Project Structure
```
pet-voting-app/
├── voting-app/              # Python Flask application
│   ├── app.py              # Main application code
│   ├── requirements.txt    # Python dependencies
│   ├── Dockerfile         # Container configuration
│   └── templates/         # HTML templates
│       └── index.html     # Voting interface
│
├── result-app/            # Node.js application
│   ├── server.js         # Main application code
│   ├── package.json      # Node.js dependencies
│   ├── Dockerfile       # Container configuration
│   └── public/          # Static files
│       └── index.html   # Results interface
│
├── worker/               # Python worker service
│   ├── worker.py        # Vote processing logic
│   ├── requirements.txt # Python dependencies
│   └── Dockerfile      # Container configuration
│
└── docker-compose.yml    # Service orchestration
```

### 2. Understanding Each Component

#### A. Voting App (Python/Flask)
- **Purpose**: Provides web interface for voting
- **Key Features**:
  - Simple HTML form with three buttons
  - RESTful API endpoint for vote submission
  - Redis integration for vote storage
```python
# Key concepts in app.py
@app.route('/vote', methods=['POST'])
def vote():
    # Store vote in Redis queue
    redis_client.rpush('votes', json.dumps({'vote': pet}))
```

#### B. Result App (Node.js)
- **Purpose**: Displays real-time voting results
- **Key Features**:
  - Socket.IO for real-time updates
  - PostgreSQL integration for vote retrieval
  - Automatic UI updates
```javascript
// Key concepts in server.js
io.on('connection', async (socket) => {
    // Send current votes to new connections
    const votes = await getVotes();
    socket.emit('current_votes', votes);
});
```

#### C. Worker Service (Python)
- **Purpose**: Processes votes from Redis to PostgreSQL
- **Key Features**:
  - Continuous vote processing
  - Database transaction handling
  - Error recovery
```python
# Key concepts in worker.py
def process_votes():
    while True:
        # Get vote from Redis and store in PostgreSQL
        vote_data = redis_client.blpop('votes', timeout=1)
```

### 3. Docker Configuration

#### A. Individual Dockerfiles
Each service has its own Dockerfile:
```dockerfile
# Example: voting-app/Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["gunicorn", "--bind", "0.0.0.0:8084", "app:app"]
```

#### B. Docker Compose Configuration
The docker-compose.yml file orchestrates all services:
```yaml
services:
  voting-app:
    build: ./voting-app
    networks:
      - frontend
      - backend
    # ... more configuration

networks:
  frontend:
  backend:
```

### 4. Networking
- **Frontend Network**: For user-accessible services
  - voting-app
  - result-app

- **Backend Network**: For internal services
  - Redis
  - PostgreSQL
  - Worker

## Running the Application

1. Install Prerequisites:
   - Docker Desktop
   - Git (for cloning the repository)

2. Clone and Build:
   ```bash
   cd pet-voting-app
   docker compose up --build
   ```

3. Access the Applications:
   - Voting Interface: http://localhost:8084
   - Results Dashboard: http://localhost:8085

## How Everything Works Together

1. **Vote Flow**:
   - User clicks a vote button → voting-app
   - voting-app → Redis queue
   - worker → processes vote from Redis
   - worker → stores in PostgreSQL
   - result-app → reads from PostgreSQL
   - Socket.IO → updates user's browser

2. **Data Flow**:
   ```
   Browser → Vote → Redis → Worker → PostgreSQL → Result App → Browser
   ```

3. **Container Communication**:
   - Services communicate through Docker networks
   - Frontend network exposes web interfaces
   - Backend network keeps databases private

## Learning Outcomes

After completing this project, you'll understand:
1. Microservices architecture
2. Container orchestration with Docker Compose
3. Full-stack development with Python and Node.js
4. Real-time web applications
5. Message queues and databases
6. Network segregation and security

## Troubleshooting

Common issues and solutions:
1. **Services not starting**: Check Docker logs
   ```bash
   docker compose logs [service-name]
   ```

2. **Can't access web interfaces**: Verify ports
   ```bash
   docker compose ps
   ```

3. **Database connection issues**: Check network configuration
   ```bash
   docker network ls
   ```

## Next Steps

Consider extending the project by:
1. Adding authentication
2. Implementing vote validation
3. Adding more visualization options
4. Setting up monitoring
5. Adding automated tests

Remember: This project demonstrates basic concepts of microservices and containerization. In a production environment, you'd need to add security measures, proper error handling, and monitoring.
