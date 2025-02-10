# Import required dependencies
# FastAPI - Modern web framework for building APIs
# HTTPException - For raising HTTP specific errors
# CORSMiddleware - To handle Cross-Origin Resource Sharing
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
# Pydantic for data validation
from pydantic import BaseModel
# SQLite for database operations
import sqlite3
# OS module for file path operations
import os

# Create FastAPI application instance with a title
app = FastAPI(title="Name Storage API")

# Configure CORS (Cross-Origin Resource Sharing)
# This allows the frontend to communicate with the backend
# '*' means all origins are allowed - in production, you might want to restrict this
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,  # Allows cookies (if needed)
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# Database initialization function
def init_db():
    """
    Initialize the SQLite database and create the names table if it doesn't exist.
    The table structure:
    - id: Auto-incrementing primary key
    - name: The stored name (required)
    - timestamp: Automatically set to current time when record is created
    """
    db_path = os.path.join(os.path.dirname(__file__), "names.db")
    conn = sqlite3.connect(db_path)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS names
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  name TEXT NOT NULL,
                  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)''')
    conn.commit()
    conn.close()

# Call init_db() when the application starts
init_db()

# Pydantic model for input validation
class NameInput(BaseModel):
    """
    Data model for name input validation.
    Ensures that the incoming request has a 'name' field.
    """
    name: str

@app.post("/names/")
async def add_name(name_input: NameInput):
    """
    POST endpoint to add a new name to the database
    Args:
        name_input (NameInput): The name to be stored
    Returns:
        dict: Confirmation message
    Raises:
        HTTPException: If the name is empty
    """
    if not name_input.name.strip():
        raise HTTPException(status_code=400, detail="Name cannot be empty")
    
    conn = sqlite3.connect("names.db")
    c = conn.cursor()
    c.execute("INSERT INTO names (name) VALUES (?)", (name_input.name,))
    conn.commit()
    conn.close()
    return {"message": f"Added name: {name_input.name}"}

@app.get("/names/")
async def get_names():
    """
    GET endpoint to retrieve the most recent names
    Returns:
        list: Last 50 names with their timestamps, ordered by most recent first
    """
    conn = sqlite3.connect("names.db")
    c = conn.cursor()
    c.execute("SELECT name, timestamp FROM names ORDER BY timestamp DESC LIMIT 50")
    names = [{"name": row[0], "timestamp": row[1]} for row in c.fetchall()]
    conn.close()
    return names
