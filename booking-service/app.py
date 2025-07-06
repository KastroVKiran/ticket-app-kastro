from flask import Flask, jsonify, render_template, request, redirect, url_for
from flask_pymongo import PyMongo
import os
import uuid
from datetime import datetime
import qrcode
import io
import base64

app = Flask(__name__)

# MongoDB connection
app.config['MONGO_URI'] = os.getenv('MONGO_URI', 'mongodb://mongo:27017/moviebooking')
mongo = PyMongo(app)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/booking')
def booking_form():
    return render_template('booking.html')

@app.route('/book', methods=['POST'])
def create_booking():
    data = request.get_json() if request.is_json else request.form
    
    booking = {
        'booking_id': str(uuid.uuid4()),
        'user_id': data.get('user_id'),
        'movie_title': data.get('movie_title'),
        'theater_name': data.get('theater_name'),
        'city': data.get('city'),
        'showtime': data.get('showtime'),
        'seats': data.get('seats', []),
        'total_amount': float(data.get('total_amount', 0)),
        'booking_date': datetime.utcnow(),
        'status': 'confirmed'
    }
    
    result = mongo.db.bookings.insert_one(booking)
    booking['_id'] = str(result.inserted_id)
    
    return jsonify({'success': True, 'booking': booking})

@app.route('/booking/<booking_id>')
def get_booking(booking_id):
    booking = mongo.db.bookings.find_one({'booking_id': booking_id})
    if booking:
        booking['_id'] = str(booking['_id'])
        return jsonify(booking)
    return jsonify({'error': 'Booking not found'}), 404

@app.route('/bookings')
def get_bookings():
    bookings = list(mongo.db.bookings.find())
    for booking in bookings:
        booking['_id'] = str(booking['_id'])
    return jsonify(bookings)

@app.route('/confirmation/<booking_id>')
def booking_confirmation(booking_id):
    booking = mongo.db.bookings.find_one({'booking_id': booking_id})
    if booking:
        # Generate QR code
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data('https://chat.whatsapp.com/EGw6ZlwUHZc82cA0vXFnwm?mode=r_c')
        qr.make(fit=True)
        
        img = qr.make_image(fill_color="black", back_color="white")
        
        # Convert to base64
        img_buffer = io.BytesIO()
        img.save(img_buffer, format='PNG')
        img_buffer.seek(0)
        img_base64 = base64.b64encode(img_buffer.getvalue()).decode()
        
        booking['qr_code'] = f"data:image/png;base64,{img_base64}"
        return render_template('confirmation.html', booking=booking)
    return "Booking not found", 404

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'booking-service'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5004, debug=True)