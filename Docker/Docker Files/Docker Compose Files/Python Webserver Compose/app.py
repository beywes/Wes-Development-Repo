# Import required libraries
from flask import Flask, jsonify, request  # Flask for web server, jsonify for JSON responses, request for handling HTTP requests
from flask_sqlalchemy import SQLAlchemy    # SQLAlchemy for database ORM
import os                                  # os for environment variables

# Initialize Flask application
app = Flask(__name__)

# Configure database connection
# Uses environment variables set in docker-compose.yml for database credentials
# Format: mysql+pymysql://username:password@hostname/database_name
app.config['SQLALCHEMY_DATABASE_URI'] = f"mysql+pymysql://{os.environ.get('MYSQL_USER')}:{os.environ.get('MYSQL_PASSWORD')}@db/{os.environ.get('MYSQL_DATABASE')}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # Disable SQLAlchemy modification tracking to save resources

# Initialize SQLAlchemy database instance
db = SQLAlchemy(app)

# Define Message database model
class Message(db.Model):
    # Define table columns
    id = db.Column(db.Integer, primary_key=True)        # Auto-incrementing ID field
    content = db.Column(db.String(200), nullable=False) # Message content, maximum 200 characters

    # Method to convert Message object to dictionary for JSON serialization
    def to_dict(self):
        return {
            'id': self.id,
            'content': self.content
        }

# Route for root endpoint - Welcome message
@app.route('/')
def hello():
    return jsonify({"message": "Welcome to Flask MySQL Docker Application!"})

# Route to get all messages - GET method
@app.route('/messages', methods=['GET'])
def get_messages():
    messages = Message.query.all()                    # Query all messages from database
    return jsonify([message.to_dict() for message in messages])  # Convert to JSON and return

# Route to create a new message - POST method
@app.route('/messages', methods=['POST'])
def add_message():
    content = request.json.get('content')            # Get content from POST request JSON body
    
    # Validate that content is provided
    if not content:
        return jsonify({"error": "Content is required"}), 400
    
    # Create new message, save to database, and return the created message
    message = Message(content=content)
    db.session.add(message)
    db.session.commit()
    return jsonify(message.to_dict()), 201          # Return 201 Created status code

# Main entry point
if __name__ == '__main__':
    # Create all database tables before running the app
    with app.app_context():
        db.create_all()
    # Run the Flask application
    app.run(host='0.0.0.0', port=8083)  # Listen on all network interfaces on port 8083
