import os
import json
import time
import redis
import psycopg2

def get_redis_client():
    return redis.Redis(host=os.getenv('REDIS_HOST', 'redis'), port=6379, db=0)

def get_postgres_connection():
    return psycopg2.connect(
        user=os.getenv('POSTGRES_USER'),
        password=os.getenv('POSTGRES_PASSWORD'),
        host=os.getenv('POSTGRES_HOST'),
        database=os.getenv('POSTGRES_DB')
    )

def init_postgres():
    conn = get_postgres_connection()
    cur = conn.cursor()
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

def process_votes():
    redis_client = get_redis_client()
    
    while True:
        try:
            # Get vote from Redis queue
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
