from flask import Flask, jsonify, render_template, request
from flask_pymongo import PyMongo
import os
from datetime import datetime, timedelta

app = Flask(__name__)

# MongoDB connection
app.config['MONGO_URI'] = os.getenv('MONGO_URI', 'mongodb://mongo:27017/moviebooking')
mongo = PyMongo(app)

# Sample theater data
THEATERS = {
    'Hyderabad': [
        {'id': 1, 'name': 'PVR Forum Mall', 'location': 'Kukatpally', 'screens': 8},
        {'id': 2, 'name': 'INOX GVK One', 'location': 'Banjara Hills', 'screens': 6},
        {'id': 3, 'name': 'AMB Cinemas', 'location': 'Gachibowli', 'screens': 4},
        {'id': 4, 'name': 'Prasads IMAX', 'location': 'Necklace Road', 'screens': 3},
        {'id': 5, 'name': 'Asian Cinemas', 'location': 'Attapur', 'screens': 5}
    ],
    'Chennai': [
        {'id': 6, 'name': 'PVR Ampa Skywalk', 'location': 'Aminjikarai', 'screens': 6},
        {'id': 7, 'name': 'INOX Express Avenue', 'location': 'Royapettah', 'screens': 8},
        {'id': 8, 'name': 'Sathyam Cinemas', 'location': 'Royapettah', 'screens': 4},
        {'id': 9, 'name': 'Escape Cinemas', 'location': 'Express Avenue', 'screens': 3},
        {'id': 10, 'name': 'Phoenix MarketCity', 'location': 'Velachery', 'screens': 7}
    ],
    'Bangalore': [
        {'id': 11, 'name': 'PVR Forum Mall', 'location': 'Koramangala', 'screens': 9},
        {'id': 12, 'name': 'INOX Mantri Square', 'location': 'Malleshwaram', 'screens': 6},
        {'id': 13, 'name': 'Cinepolis Royal Meenakshi', 'location': 'Bannerghatta Road', 'screens': 5},
        {'id': 14, 'name': 'Innovative Multiplex', 'location': 'JP Nagar', 'screens': 4},
        {'id': 15, 'name': 'Fun Cinemas', 'location': 'SBS Mall', 'screens': 3}
    ],
    'Mumbai': [
        {'id': 16, 'name': 'PVR Phoenix Mills', 'location': 'Lower Parel', 'screens': 8},
        {'id': 17, 'name': 'INOX Megaplex', 'location': 'Inorbit Mall', 'screens': 7},
        {'id': 18, 'name': 'Cinepolis Fun Republic', 'location': 'Andheri West', 'screens': 6},
        {'id': 19, 'name': 'PVR Icon', 'location': 'Versova', 'screens': 5},
        {'id': 20, 'name': 'MovieMax Cinemas', 'location': 'Sion', 'screens': 4}
    ],
    'Delhi': [
        {'id': 21, 'name': 'PVR Select City Walk', 'location': 'Saket', 'screens': 10},
        {'id': 22, 'name': 'INOX Nehru Place', 'location': 'Nehru Place', 'screens': 6},
        {'id': 23, 'name': 'Cinepolis DLF Mall', 'location': 'Noida', 'screens': 8},
        {'id': 24, 'name': 'PVR Priya', 'location': 'Vasant Vihar', 'screens': 4},
        {'id': 25, 'name': 'Wave Cinemas', 'location': 'Rajouri Garden', 'screens': 5}
    ]
}

SHOWTIMES = ['10:00 AM', '01:00 PM', '04:00 PM', '07:00 PM', '10:00 PM']

@app.route('/')
def index():
    return render_template('index.html', theaters=THEATERS, showtimes=SHOWTIMES)

@app.route('/theaters')
def get_theaters():
    return jsonify(THEATERS)

@app.route('/theaters/<city>')
def get_theaters_by_city(city):
    city_theaters = THEATERS.get(city, [])
    return jsonify(city_theaters)

@app.route('/theaters/<city>/<int:theater_id>')
def get_theater_details(city, theater_id):
    city_theaters = THEATERS.get(city, [])
    theater = next((t for t in city_theaters if t['id'] == theater_id), None)
    if theater:
        return jsonify(theater)
    return jsonify({'error': 'Theater not found'}), 404

@app.route('/showtimes')
def get_showtimes():
    return jsonify(SHOWTIMES)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'theater-service'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True)