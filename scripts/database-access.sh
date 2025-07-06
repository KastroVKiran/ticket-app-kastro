#!/bin/bash

echo "=========================================="
echo "🗄️ MONGODB DATABASE ACCESS GUIDE"
echo "=========================================="
echo ""

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name kastro-eks >/dev/null 2>&1

# Get MongoDB pod name
MONGO_POD=$(kubectl get pods -n moviebox -l app=mongo -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ ! -z "$MONGO_POD" ]; then
    echo "✅ MongoDB pod found: $MONGO_POD"
    echo ""
    echo "🔧 DATABASE ACCESS COMMANDS:"
    echo ""
    echo "1. Connect to MongoDB shell:"
    echo "   kubectl exec -it $MONGO_POD -n moviebox -- mongosh"
    echo ""
    echo "2. Once inside MongoDB shell, run these commands:"
    echo "   use moviebooking"
    echo "   show collections"
    echo ""
    echo "3. Query different collections:"
    echo "   # View all users"
    echo "   db.users.find().pretty()"
    echo ""
    echo "   # View all bookings"
    echo "   db.bookings.find().pretty()"
    echo ""
    echo "   # View all payments"
    echo "   db.payments.find().pretty()"
    echo ""
    echo "   # Count documents in each collection"
    echo "   db.users.countDocuments()"
    echo "   db.bookings.countDocuments()"
    echo "   db.payments.countDocuments()"
    echo ""
    echo "   # Find specific user by email"
    echo "   db.users.findOne({email: \"user@example.com\"})"
    echo ""
    echo "   # Find bookings by status"
    echo "   db.bookings.find({status: \"confirmed\"})"
    echo ""
    echo "   # Find recent bookings (last 24 hours)"
    echo "   db.bookings.find({booking_date: {\$gte: new Date(Date.now() - 24*60*60*1000)}})"
    echo ""
    echo "4. Exit MongoDB shell:"
    echo "   exit"
    echo ""
    echo "🔍 QUICK DATABASE INSPECTION:"
    echo "Let's check what's currently in the database..."
    echo ""
    
    # Quick database check
    kubectl exec $MONGO_POD -n moviebox -- mongosh --eval "
    use moviebooking;
    print('=== Database Collections ===');
    show collections;
    print('');
    print('=== Users Count ===');
    print('Total users: ' + db.users.countDocuments());
    print('');
    print('=== Bookings Count ===');
    print('Total bookings: ' + db.bookings.countDocuments());
    print('');
    print('=== Payments Count ===');
    print('Total payments: ' + db.payments.countDocuments());
    print('');
    if(db.users.countDocuments() > 0) {
        print('=== Sample User ===');
        printjson(db.users.findOne());
    }
    if(db.bookings.countDocuments() > 0) {
        print('=== Sample Booking ===');
        printjson(db.bookings.findOne());
    }
    " 2>/dev/null || echo "Could not connect to MongoDB"
    
else
    echo "❌ MongoDB pod not found!"
    echo ""
    echo "Check if MongoDB is running:"
    echo "kubectl get pods -n moviebox -l app=mongo"
    echo ""
    echo "If no pods are found, deploy MongoDB:"
    echo "kubectl apply -f k8s/mongodb-deployment.yaml"
fi

echo ""
echo "=========================================="
