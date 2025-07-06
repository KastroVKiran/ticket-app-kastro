#!/bin/bash

# Build and push all Docker images
echo "Building and pushing all Docker images..."

# Build and push user-service
cd user-service
docker build -t kastrov/user-service:latest .
docker push kastrov/user-service:latest
cd ..

# Build and push movie-service
cd movie-service
docker build -t kastrov/movie-service:latest .
docker push kastrov/movie-service:latest
cd ..

# Build and push theater-service
cd theater-service
docker build -t kastrov/theater-service:latest .
docker push kastrov/theater-service:latest
cd ..

# Build and push booking-service
cd booking-service
docker build -t kastrov/booking-service:latest .
docker push kastrov/booking-service:latest
cd ..

# Build and push payment-service
cd payment-service
docker build -t kastrov/payment-service:latest .
docker push kastrov/payment-service:latest
cd ..

echo "All Docker images built and pushed successfully!"