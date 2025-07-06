from flask import Flask, jsonify, render_template, request
from flask_pymongo import PyMongo
import os
import uuid
import requests
from datetime import datetime
import time

app = Flask(__name__)

# MongoDB connection
app.config['MONGO_URI'] = os.getenv('MONGO_URI', 'mongodb://mongo:27017/moviebooking')
mongo = PyMongo(app)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/process', methods=['POST'])
def process_payment():
    data = request.get_json() if request.is_json else request.form
    
    # Create booking first
    booking_id = str(uuid.uuid4())
    booking = {
        'booking_id': booking_id,
        'user_id': data.get('user_id'),
        'movie_title': data.get('movie_title'),
        'theater_name': data.get('theater_name'),
        'city': data.get('city'),
        'showtime': data.get('showtime'),
        'seats': [f'A{i}' for i in range(1, int(data.get('seats', 1)) + 1)],
        'total_amount': float(data.get('total_amount', 0)),
        'booking_date': datetime.utcnow(),
        'status': 'pending'
    }
    
    # Insert booking
    mongo.db.bookings.insert_one(booking)
    
    # Simulate payment processing
    time.sleep(2)
    
    # Create payment record
    payment = {
        'payment_id': str(uuid.uuid4()),
        'booking_id': booking_id,
        'amount': float(data.get('total_amount', 0)),
        'payment_method': 'credit_card',
        'status': 'success',
        'transaction_id': f'TXN{int(time.time())}',
        'payment_date': datetime.utcnow()
    }
    
    mongo.db.payments.insert_one(payment)
    
    # Update booking status
    mongo.db.bookings.update_one(
        {'booking_id': booking_id},
        {'$set': {'status': 'confirmed'}}
    )
    
    return jsonify({
        'success': True,
        'booking_id': booking_id,
        'payment_id': payment['payment_id'],
        'transaction_id': payment['transaction_id']
    })

@app.route('/payment/<payment_id>')
def get_payment(payment_id):
    payment = mongo.db.payments.find_one({'payment_id': payment_id})
    if payment:
        payment['_id'] = str(payment['_id'])
        return jsonify(payment)
    return jsonify({'error': 'Payment not found'}), 404

@app.route('/payments')
def get_payments():
    payments = list(mongo.db.payments.find())
    for payment in payments:
        payment['_id'] = str(payment['_id'])
    return jsonify(payments)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'payment-service'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005, debug=True)