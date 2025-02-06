from flask import Flask, render_template, request, jsonify
import redis
import os
import json

app = Flask(__name__)
redis_client = redis.Redis(host=os.getenv('REDIS_HOST', 'redis'), port=6379, db=0)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/vote', methods=['POST'])
def vote():
    pet = request.json.get('pet')
    if pet in ['dogs', 'cats', 'lizards']:
        redis_client.rpush('votes', json.dumps({'vote': pet}))
        return jsonify({'status': 'success'})
    return jsonify({'status': 'error', 'message': 'Invalid pet choice'}), 400

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8084)
