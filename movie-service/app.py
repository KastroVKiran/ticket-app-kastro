from flask import Flask, jsonify, render_template, request
from flask_pymongo import PyMongo
import os
from datetime import datetime

app = Flask(__name__)

# MongoDB connection
app.config['MONGO_URI'] = os.getenv('MONGO_URI', 'mongodb://mongo:27017/moviebooking')
mongo = PyMongo(app)

# Sample movie data
MOVIES = [
    {
        'id': 1,
        'title': 'Avengers: Endgame',
        'industry': 'Hollywood',
        'genre': 'Action/Adventure',
        'duration': '181 min',
        'rating': '8.4',
        'image': 'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?auto=compress&cs=tinysrgb&w=400',
        'description': 'The epic conclusion to the Marvel Cinematic Universe saga.'
    },
    {
        'id': 2,
        'title': 'RRR',
        'industry': 'Tollywood',
        'genre': 'Action/Drama',
        'duration': '187 min',
        'rating': '8.8',
        'image': 'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?auto=compress&cs=tinysrgb&w=400',
        'description': 'A fictional story about two legendary revolutionaries.'
    },
    {
        'id': 3,
        'title': 'Dangal',
        'industry': 'Bollywood',
        'genre': 'Biography/Drama',
        'duration': '161 min',
        'rating': '8.3',
        'image': 'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?auto=compress&cs=tinysrgb&w=400',
        'description': 'A former wrestler trains his daughters to become world champions.'
    },
    {
        'id': 4,
        'title': 'Vikram',
        'industry': 'Kollywood',
        'genre': 'Action/Thriller',
        'duration': '174 min',
        'rating': '8.2',
        'image': 'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?auto=compress&cs=tinysrgb&w=400',
        'description': 'A black-ops agent goes on a mission to hunt down a group of masked vigilantes.'
    },
    {
        'id': 5,
        'title': 'Drishyam 2',
        'industry': 'Mollywood',
        'genre': 'Crime/Drama',
        'duration': '152 min',
        'rating': '8.4',
        'image': 'https://images.pexels.com/photos/7991579/pexels-photo-7991579.jpeg?auto=compress&cs=tinysrgb&w=400',
        'description': 'The sequel to the critically acclaimed thriller Drishyam.'
    }
]

@app.route('/')
def index():
    return render_template('index.html', movies=MOVIES)

@app.route('/movies')
def get_movies():
    return jsonify(MOVIES)

@app.route('/movies/<int:movie_id>')
def get_movie(movie_id):
    movie = next((m for m in MOVIES if m['id'] == movie_id), None)
    if movie:
        return jsonify(movie)
    return jsonify({'error': 'Movie not found'}), 404

@app.route('/movies/search')
def search_movies():
    query = request.args.get('q', '').lower()
    industry = request.args.get('industry', '')
    
    filtered_movies = MOVIES
    
    if query:
        filtered_movies = [m for m in filtered_movies if query in m['title'].lower()]
    
    if industry:
        filtered_movies = [m for m in filtered_movies if industry.lower() in m['industry'].lower()]
    
    return jsonify(filtered_movies)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'movie-service'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)