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
8. [Detailed Code Explanations](#detailed-code-explanations)

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

## Detailed Code Explanations

### 1. Voting Application (Python/Flask)

#### app.py
```python
# Import necessary libraries
from flask import Flask, render_template, request, jsonify  
# Flask: Web framework for creating the application
# render_template: Function to render HTML templates
# request: Object to handle HTTP requests
# jsonify: Function to convert Python dictionaries to JSON responses

import redis  # Redis client library for Python
import os     # Operating system interface for environment variables
import json   # JSON handling library

# Initialize Flask application
app = Flask(__name__)

# Create Redis client connection
# os.getenv('REDIS_HOST', 'redis'): Get Redis host from environment variable,
# default to 'redis' if not set (Docker service name)
redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'redis'),  
    port=6379,  # Default Redis port
    db=0        # Redis database number
)

# Route for the main page
@app.route('/')
def index():
    # Render the voting interface template
    return render_template('index.html')

# Route to handle voting
@app.route('/vote', methods=['POST'])
def vote():
    # Get the pet choice from the JSON request body
    pet = request.json.get('pet')
    
    # Validate that the pet choice is valid
    if pet in ['dogs', 'cats', 'lizards']:
        # Convert vote to JSON and push to Redis list named 'votes'
        redis_client.rpush('votes', json.dumps({'vote': pet}))
        # Return success response
        return jsonify({'status': 'success'})
    
    # Return error if invalid pet choice
    return jsonify({
        'status': 'error',
        'message': 'Invalid pet choice'
    }), 400

# Start the application
if __name__ == '__main__':
    # Run on all network interfaces (0.0.0.0) on port 8084
    app.run(host='0.0.0.0', port=8084)
```

### 2. Result Application (Node.js)

#### server.js
```javascript
// Import required modules
const express = require('express');     // Web framework
const { Pool } = require('pg');         // PostgreSQL client
const socketIO = require('socket.io');  // Real-time communication
const path = require('path');           // File path handling

// Initialize Express application
const app = express();
const server = require('http').Server(app);
const io = socketIO(server);

// Configure PostgreSQL connection
const pool = new Pool({
    // Get database configuration from environment variables
    user: process.env.POSTGRES_USER,
    host: process.env.POSTGRES_HOST,
    database: process.env.POSTGRES_DB,
    password: process.env.POSTGRES_PASSWORD,
    port: 5432  // Default PostgreSQL port
});

// Serve static files from 'public' directory
app.use(express.static('public'));

// Route for main page
app.get('/', (req, res) => {
    // Send the results interface HTML file
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Function to get vote counts from database
async function getVotes() {
    // Query to count votes for each pet
    const result = await pool.query(
        'SELECT pet, COUNT(*) as count FROM votes GROUP BY pet'
    );
    
    // Convert query results to an object with default values
    return result.rows.reduce((acc, row) => {
        acc[row.pet] = parseInt(row.count);
        return acc;
    }, { dogs: 0, cats: 0, lizards: 0 });
}

// Handle WebSocket connections
io.on('connection', async (socket) => {
    // When a client connects, send current vote counts
    const votes = await getVotes();
    socket.emit('current_votes', votes);
});

// Update all clients every 2 seconds
setInterval(async () => {
    const votes = await getVotes();
    io.emit('current_votes', votes);
}, 2000);

// Start the server
const port = process.env.PORT || 8085;
server.listen(port, () => {
    console.log(`Result app listening at http://localhost:${port}`);
});
```

### 3. Worker Service (Python)

#### worker.py
```python
# Import required libraries
import os       # Operating system interface
import json     # JSON handling
import time     # Time-related functions
import redis    # Redis client
import psycopg2 # PostgreSQL client

# Function to create Redis connection
def get_redis_client():
    return redis.Redis(
        # Get Redis host from environment variable
        host=os.getenv('REDIS_HOST', 'redis'),
        port=6379,
        db=0
    )

# Function to create PostgreSQL connection
def get_postgres_connection():
    return psycopg2.connect(
        # Get PostgreSQL configuration from environment variables
        user=os.getenv('POSTGRES_USER'),
        password=os.getenv('POSTGRES_PASSWORD'),
        host=os.getenv('POSTGRES_HOST'),
        database=os.getenv('POSTGRES_DB')
    )

# Initialize PostgreSQL database
def init_postgres():
    conn = get_postgres_connection()
    cur = conn.cursor()
    # Create votes table if it doesn't exist
    cur.execute('''
        CREATE TABLE IF NOT EXISTS votes (
            id SERIAL PRIMARY KEY,
            pet VARCHAR(10) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    cur.close()
    conn.close()

# Main vote processing function
def process_votes():
    redis_client = get_redis_client()
    
    while True:
        try:
            # Wait for new vote in Redis queue
            vote_data = redis_client.blpop('votes', timeout=1)
            
            if vote_data:
                # Process the vote
                vote = json.loads(vote_data[1])
                conn = get_postgres_connection()
                cur = conn.cursor()
                
                # Insert vote into PostgreSQL
                cur.execute(
                    'INSERT INTO votes (pet) VALUES (%s)',
                    (vote['vote'],)
                )
                conn.commit()
                cur.close()
                conn.close()
                
        except Exception as e:
            print(f"Error processing vote: {e}")
            time.sleep(1)

# Application entry point
if __name__ == '__main__':
    # Wait for PostgreSQL to be ready
    while True:
        try:
            init_postgres()
            break
        except psycopg2.OperationalError:
            print("Waiting for PostgreSQL...")
            time.sleep(1)
    
    print("Worker started, processing votes...")
    process_votes()
```

### 4. Service Connections and Data Flow

#### How Services Communicate

1. **Voting App → Redis**
```python
# In voting-app/app.py
redis_client.rpush('votes', json.dumps({'vote': pet}))
```
- Voting app pushes new votes to Redis list
- Uses Redis as a message queue
- Data is JSON-encoded for consistency

2. **Worker → Redis → PostgreSQL**
```python
# In worker/worker.py
vote_data = redis_client.blpop('votes', timeout=1)  # Get from Redis
cur.execute('INSERT INTO votes (pet) VALUES (%s)')   # Store in PostgreSQL
```
- Worker continuously monitors Redis queue
- Processes votes and stores in PostgreSQL
- Handles connection errors gracefully

3. **Result App → PostgreSQL**
```javascript
// In result-app/server.js
const result = await pool.query('SELECT pet, COUNT(*) as count FROM votes GROUP BY pet');
io.emit('current_votes', votes);
```
- Queries vote counts from PostgreSQL
- Broadcasts results via WebSocket
- Updates clients in real-time

#### Docker Network Configuration
```yaml
# In docker-compose.yml
services:
  voting-app:
    networks:
      - frontend    # For web access
      - backend     # For Redis access
  
  result-app:
    networks:
      - frontend    # For web access
      - backend     # For PostgreSQL access
  
  worker:
    networks:
      - backend     # Internal only
  
  redis:
    networks:
      - backend     # Internal only
  
  db:
    networks:
      - backend     # Internal only
```

### 5. Data Flow Sequence

1. **Vote Submission**:
   ```
   User → voting-app → Redis
   ```
   - User clicks vote button
   - Frontend JavaScript sends POST request
   - Flask app stores vote in Redis

2. **Vote Processing**:
   ```
   Redis → worker → PostgreSQL
   ```
   - Worker retrieves vote from Redis
   - Processes and validates vote
   - Stores in PostgreSQL

3. **Results Display**:
   ```
   PostgreSQL → result-app → Browser
   ```
   - Node.js queries PostgreSQL
   - Sends updates via Socket.IO
   - Browser updates UI in real-time

This architecture ensures:
- Loose coupling between services
- Scalability of components
- Real-time updates
- Data persistence
- Fault tolerance

Each component can be scaled or modified independently without affecting others, demonstrating key microservices principles.

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
