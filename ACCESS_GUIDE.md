# 🎬 MovieBox Application - Complete Access Guide

## 🌐 Application URLs

Your MovieBox application is accessible via the AWS LoadBalancer URL. No need for `.local` domain configuration.

### Main Access Points:
- **Main Application**: `http://ae540a2aba9a74d89b03e0f526172b2d-5538fd20c1961f6d.elb.us-east-1.amazonaws.com`
- **User Service**: `http://ae540a2aba9a74d89b03e0f526172b2d-5538fd20c1961f6d.elb.us-east-1.amazonaws.com/user-service`
- **Movie Service**: `http://ae540a2aba9a74d89b03e0f526172b2d-5538fd20c1961f6d.elb.us-east-1.amazonaws.com/movie-service`
- **Theater Service**: `http://ae540a2aba9a74d89b03e0f526172b2d-5538fd20c1961f6d.elb.us-east-1.amazonaws.com/theater-service`
- **Booking Service**: `http://ae540a2aba9a74d89b03e0f526172b2d-5538fd20c1961f6d.elb.us-east-1.amazonaws.com/booking-service`
- **Payment Service**: `http://ae540a2aba9a74d89b03e0f526172b2d-5538fd20c1961f6d.elb.us-east-1.amazonaws.com/payment-service`

### Admin Dashboard:
- **Admin Panel**: `http://ae540a2aba9a74d89b03e0f526172b2d-5538fd20c1961f6d.elb.us-east-1.amazonaws.com/user-service/admin`

## 👤 User Credentials

### Regular Users:
- **Registration**: Visit the main URL and click "Register"
- **Create Account**: Fill in name, email, and password
- **Login**: Use your registered credentials

### Test User Accounts:
You can create any user account through the registration form. No pre-configured accounts exist.

**Sample Registration:**
- Name: `John Doe`
- Email: `john@example.com`
- Password: `password123`

### Admin Access:
- **Admin Dashboard**: Direct access (no authentication required for demo)
- **URL**: `http://[LoadBalancer-URL]/user-service/admin`

## 🗄️ Database Access Commands

### Connect to MongoDB:
```bash
# Get MongoDB pod name
kubectl get pods -n moviebox -l app=mongo

# Connect to MongoDB shell
kubectl exec -it $(kubectl get pods -n moviebox -l app=mongo -o jsonpath='{.items[0].metadata.name}') -n moviebox -- mongosh
```

### Inside MongoDB Shell:
```javascript
// Switch to application database
use moviebooking

// Show all collections
show collections

// View all users
db.users.find().pretty()

// View all bookings
db.bookings.find().pretty()

// View all payments
db.payments.find().pretty()

// Count documents
db.users.countDocuments()
db.bookings.countDocuments()
db.payments.countDocuments()

// Find specific user
db.users.findOne({email: "john@example.com"})

// Find confirmed bookings
db.bookings.find({status: "confirmed"})

// Find recent bookings (last 24 hours)
db.bookings.find({booking_date: {$gte: new Date(Date.now() - 24*60*60*1000)}})

// Exit
exit
```

### Quick Database Check Script:
```bash
# Run the database access script
chmod +x scripts/database-access.sh
./scripts/database-access.sh
```

## 🎯 Application Testing Flow

### 1. User Registration & Login:
1. Visit the main application URL
2. Click "Register" in the navigation
3. Fill in your details (name, email, password)
4. Click "Register" button
5. Go to "Login" and use your credentials

### 2. Browse Movies:
1. Click "Movies" in navigation or visit `/movie-service`
2. Filter by industry (Hollywood, Bollywood, Tollywood, etc.)
3. View movie details and ratings

### 3. Select Theaters:
1. Click "Theaters" in navigation or visit `/theater-service`
2. Choose from 5 cities: Hyderabad, Chennai, Bangalore, Mumbai, Delhi
3. View available theaters and showtimes

### 4. Book Tickets:
1. Click "Bookings" in navigation or visit `/booking-service`
2. Select city, movie, theater, showtime, and number of seats
3. Review total amount (₹200 per seat + ₹50 convenience fee)
4. Click "Proceed to Payment"

### 5. Payment Process:
1. Fill in fake credit card details
2. Click "Pay Now"
3. Wait for payment processing simulation

### 6. Confirmation:
1. Get booking confirmation with QR code
2. QR code links to WhatsApp group
3. Print ticket option available

## 📱 WhatsApp Integration

The QR code in booking confirmation links to:
`https://chat.whatsapp.com/EGw6ZlwUHZc82cA0vXFnwm?mode=r_c`

## 🔗 Social Media Links

- **YouTube**: https://www.youtube.com/@LearnWithKASTRO
- **LinkedIn**: https://linkedin.com/in/kastro-kiran

## 🛠️ Troubleshooting Commands

### Check Application Status:
```bash
# Check all pods
kubectl get pods -n moviebox

# Check services
kubectl get services -n moviebox

# Check ingress
kubectl get ingress -n moviebox

# Get LoadBalancer URL
kubectl get svc ingress-nginx-controller -n ingress-nginx
```

### View Logs:
```bash
# View specific service logs
kubectl logs -f deployment/user-service -n moviebox
kubectl logs -f deployment/movie-service -n moviebox
kubectl logs -f deployment/theater-service -n moviebox
kubectl logs -f deployment/booking-service -n moviebox
kubectl logs -f deployment/payment-service -n moviebox
```

### Quick Access Info:
```bash
# Run the access info script
chmod +x scripts/get-access-info.sh
./scripts/get-access-info.sh
```

## 🎬 Available Movies

### Hollywood:
- Avengers: Endgame (Action/Adventure, 181 min, 8.4★)

### Bollywood:
- Dangal (Biography/Drama, 161 min, 8.3★)

### Tollywood:
- RRR (Action/Drama, 187 min, 8.8★)

### Kollywood:
- Vikram (Action/Thriller, 174 min, 8.2★)

### Mollywood:
- Drishyam 2 (Crime/Drama, 152 min, 8.4★)

## 🏢 Available Cities & Theaters

### Hyderabad:
- PVR Forum Mall (Kukatpally)
- INOX GVK One (Banjara Hills)
- AMB Cinemas (Gachibowli)
- Prasads IMAX (Necklace Road)
- Asian Cinemas (Attapur)

### Chennai:
- PVR Ampa Skywalk (Aminjikarai)
- INOX Express Avenue (Royapettah)
- Sathyam Cinemas (Royapettah)
- Escape Cinemas (Express Avenue)
- Phoenix MarketCity (Velachery)

### Bangalore:
- PVR Forum Mall (Koramangala)
- INOX Mantri Square (Malleshwaram)
- Cinepolis Royal Meenakshi (Bannerghatta Road)
- Innovative Multiplex (JP Nagar)
- Fun Cinemas (SBS Mall)

### Mumbai:
- PVR Phoenix Mills (Lower Parel)
- INOX Megaplex (Inorbit Mall)
- Cinepolis Fun Republic (Andheri West)
- PVR Icon (Versova)
- MovieMax Cinemas (Sion)

### Delhi:
- PVR Select City Walk (Saket)
- INOX Nehru Place (Nehru Place)
- Cinepolis DLF Mall (Noida)
- PVR Priya (Vasant Vihar)
- Wave Cinemas (Rajouri Garden)

## 🕐 Available Showtimes:
- 10:00 AM
- 01:00 PM
- 04:00 PM
- 07:00 PM
- 10:00 PM

---

**Enjoy your MovieBox experience! 🍿🎬**
