# Name Storage App

A simple containerized application demonstrating database persistence using Python, FastAPI, SQLite, and a modern web frontend.

## Features

- Add names through a clean, modern interface
- Automatically displays the 50 most recent names
- Persistent storage using SQLite database
- Real-time updates every 5 seconds
- Clear explanation of the database interaction flow

## Architecture

- **Frontend**: HTML/JavaScript with Tailwind CSS for styling
- **Backend**: FastAPI (Python) with SQLite database
- **Database**: SQLite3 with persistent volume storage
- **Containers**: Docker with docker-compose orchestration

## How it Works

1. The frontend provides a simple form to input names
2. When a name is submitted:
   - Frontend sends a POST request to the backend API
   - Backend stores the name in SQLite with a timestamp
   - Frontend refreshes to show the updated list
3. The database persists data using Docker volumes
4. The frontend polls for updates every 5 seconds

## Running the Application

1. Make sure Docker and docker-compose are installed
2. Clone this repository
3. Run the application:
   ```bash
   docker-compose up --build
   ```
4. Access the application at http://localhost

## API Endpoints

- `POST /names/`: Add a new name
- `GET /names/`: Retrieve the 50 most recent names
