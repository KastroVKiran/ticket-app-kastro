# MovieBox - Microservices Movie Booking Application

A complete movie ticket booking application built with microservices architecture, designed for deployment on AWS EKS with Jenkins CI/CD pipeline.

## 🏗️ Architecture

This application consists of 5 microservices:

1. **User Service** (Port 5001) - User authentication and management
2. **Movie Service** (Port 5002) - Movie catalog and information
3. **Theater Service** (Port 5003) - Theater and showtime management
4. **Booking Service** (Port 5004) - Ticket booking and seat selection
5. **Payment Service** (Port 5005) - Payment processing

## 🚀 Features

- **Modern UI**: Beautiful, responsive design with glass-morphism effects
- **Multi-city Support**: 5 major cities (Hyderabad, Chennai, Bangalore, Mumbai, Delhi)
- **Multi-industry Movies**: Hollywood, Bollywood, Tollywood, Kollywood, Mollywood
- **Real-time Booking**: Instant ticket confirmation with QR codes
- **WhatsApp Integration**: QR code links to WhatsApp group
- **Admin Dashboard**: Comprehensive admin interface
- **Secure Payment**: Simulated payment processing
- **Containerized**: Docker containers for all services
- **Kubernetes Ready**: Complete K8s deployment files
- **CI/CD Pipeline**: Jenkins pipeline for automated deployment

## 🛠️ Tech Stack

- **Backend**: Python Flask
- **Frontend**: HTML, CSS (Tailwind), JavaScript
- **Database**: MongoDB
- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **CI/CD**: Jenkins
- **Cloud**: AWS EKS
- **Ingress**: NGINX Ingress Controller

## 📁 Project Structure

```
movie-booking-app/
├── user-service/
│   ├── app.py
│   ├── templates/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── requirements.txt
├── movie-service/
│   ├── app.py
│   ├── templates/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── requirements.txt
├── theater-service/
│   ├── app.py
│   ├── templates/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── requirements.txt
├── booking-service/
│   ├── app.py
│   ├── templates/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── requirements.txt
├── payment-service/
│   ├── app.py
│   ├── templates/
│   ├── Dockerfile
│   ├── Jenkinsfile
│   └── requirements.txt
├── k8s/
│   ├── namespace.yaml
│   ├── mongodb-deployment.yaml
│   ├── *-service-deployment.yaml
│   ├── *-service-service.yaml
│   ├── ingress.yaml
│   └── ingress-controller-install.sh
├── scripts/
│   ├── build-and-push.sh
│   └── deploy-all.sh
├── docker-compose.yml
├── Jenkinsfile
└── README.md
```

## 🔧 Prerequisites

### Local Development
- Docker and Docker Compose
- Python 3.11+
- MongoDB

### AWS EKS Deployment
- AWS CLI configured
- kubectl installed
- EKS cluster (kastro-eks) running
- Jenkins server with required plugins

### Jenkins Configuration
- **Docker Hub Credentials**: `dockerhub-creds`
- **AWS Credentials**: `aws-creds`
- **Docker Tool**: `docker`

## 🚀 Local Development

### Using Docker Compose

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd movie-booking-app
   ```

2. **Start all services**
   ```bash
   docker-compose up -d
   ```

3. **Access the application**
   - User Service: http://localhost:5001
   - Movie Service: http://localhost:5002
   - Theater Service: http://localhost:5003
   - Booking Service: http://localhost:5004
   - Payment Service: http://localhost:5005

4. **Access MongoDB**
   ```bash
   # Connect to MongoDB container
   docker exec -it mongo mongosh
   
   # Use the database
   use moviebooking
   
   # Show collections
   show collections
   
   # Query users
   db.users.find()
   
   # Query bookings
   db.bookings.find()
   ```

## ☁️ AWS EKS Deployment

### 1. EKS Cluster Setup

```bash
# Create EKS cluster (if not already created)
eksctl create cluster --name kastro-eks --region us-east-1 --nodegroup-name standard-workers --node-type t3.medium --nodes 3 --nodes-min 1 --nodes-max 4

# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name kastro-eks
```

### 2. Security Group Configuration

**EKS Client VM (Jenkins Server):**
- SSH (22): Your IP
- HTTP (80): Your IP
- HTTPS (443): Your IP
- Custom (8080): Your IP (Jenkins)

**EKS Worker Nodes:**
- All traffic from EKS Client VM
- HTTP (80): 0.0.0.0/0
- HTTPS (443): 0.0.0.0/0
- Node Port Range (30000-32767): 0.0.0.0/0

### 3. Install NGINX Ingress Controller

```bash
# Make script executable
chmod +x k8s/ingress-controller-install.sh

# Install ingress controller
./k8s/ingress-controller-install.sh
```

### 4. Deploy Application

**Option A: Manual Deployment**
```bash
# Deploy all services
chmod +x scripts/deploy-all.sh
./scripts/deploy-all.sh
```

**Option B: Jenkins Pipeline**
1. Create a new Jenkins pipeline job
2. Configure it to use the main `Jenkinsfile`
3. Enable "Build with Parameters" if needed
4. Run the pipeline

### 5. Configure DNS

```bash
# Get LoadBalancer external IP
kubectl get svc ingress-nginx-controller -n ingress-nginx

# Add to /etc/hosts or configure DNS
echo "<EXTERNAL-IP> moviebox.local" >> /etc/hosts
```

## 🔧 Jenkins Pipeline Configuration

### Individual Service Pipelines

Each service has its own Jenkinsfile for individual deployment:

1. **Create pipeline jobs** for each service:
   - user-service-pipeline
   - movie-service-pipeline
   - theater-service-pipeline
   - booking-service-pipeline
   - payment-service-pipeline

2. **Configure each pipeline**:
   - Source Code Management: Git
   - Branch: main
   - Script Path: `{service-name}/Jenkinsfile`

### Main Pipeline

For deploying all services together:
1. Create a pipeline job named "moviebox-deploy-all"
2. Use the main `Jenkinsfile`
3. Enable "Build with Parameters" for build number control

## 🧪 Testing the Application

### Health Checks
```bash
# Check all services
kubectl get pods -n moviebox
kubectl get services -n moviebox

# Test health endpoints
curl http://moviebox.local/user-service/health
curl http://moviebox.local/movie-service/health
curl http://moviebox.local/theater-service/health
curl http://moviebox.local/booking-service/health
curl http://moviebox.local/payment-service/health
```

### Application Flow
1. **Access the application**: http://moviebox.local
2. **Register/Login**: Create a new user account
3. **Browse Movies**: View available movies
4. **Select Theater**: Choose city and theater
5. **Book Tickets**: Select seats and proceed to payment
6. **Make Payment**: Complete fake payment process
7. **Get Confirmation**: Receive booking confirmation with QR code

## 🗄️ Database Access

### MongoDB Commands
```bash
# Access MongoDB pod
kubectl exec -it <mongo-pod-name> -n moviebox -- mongosh

# Database operations
use moviebooking
show collections
db.users.find()
db.bookings.find()
db.payments.find()

# Sample queries
db.bookings.find({status: "confirmed"})
db.users.find({email: "user@example.com"})
```

## 📊 Monitoring and Logs

### View Logs
```bash
# View service logs
kubectl logs -f deployment/user-service -n moviebox
kubectl logs -f deployment/movie-service -n moviebox
kubectl logs -f deployment/theater-service -n moviebox
kubectl logs -f deployment/booking-service -n moviebox
kubectl logs -f deployment/payment-service -n moviebox

# View ingress logs
kubectl logs -f -n ingress-nginx deployment/ingress-nginx-controller
```

### Monitoring
```bash
# Check resource usage
kubectl top pods -n moviebox
kubectl top nodes

# Check ingress
kubectl describe ingress moviebox-ingress -n moviebox
```

## 🔍 Troubleshooting

### Common Issues

1. **Services not accessible**
   - Check ingress controller status
   - Verify DNS/hosts file configuration
   - Check service endpoints

2. **Database connection issues**
   - Ensure MongoDB pod is running
   - Check connection strings in environment variables

3. **Image pull errors**
   - Verify DockerHub credentials
   - Check image names and tags

4. **Jenkins build failures**
   - Verify AWS credentials
   - Check kubectl configuration
   - Ensure EKS cluster is accessible

### Debug Commands
```bash
# Check pod status
kubectl describe pod <pod-name> -n moviebox

# Check service endpoints
kubectl get endpoints -n moviebox

# Check ingress
kubectl describe ingress -n moviebox

# Check ConfigMaps and Secrets
kubectl get configmaps -n moviebox
kubectl get secrets -n moviebox
```

## 🔄 Scaling

### Manual Scaling
```bash
# Scale individual services
kubectl scale deployment user-service --replicas=3 -n moviebox
kubectl scale deployment movie-service --replicas=3 -n moviebox
```

### Auto-scaling
```yaml
# Add to deployment files
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: user-service-hpa
  namespace: moviebox
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: user-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🔐 Security Considerations

- **Network Policies**: Implement Kubernetes network policies
- **RBAC**: Configure Role-Based Access Control
- **Secrets Management**: Use Kubernetes secrets for sensitive data
- **Image Security**: Scan container images for vulnerabilities
- **TLS/SSL**: Enable HTTPS in production

## 📈 Performance Optimization

- **Resource Limits**: Set appropriate resource limits and requests
- **Caching**: Implement Redis for caching
- **Database Optimization**: Add indexes to MongoDB collections
- **Load Balancing**: Use multiple replicas for high availability

## 🌐 Production Considerations

1. **Domain Configuration**: Replace `moviebox.local` with actual domain
2. **SSL Certificate**: Configure SSL/TLS certificates
3. **Environment Variables**: Use ConfigMaps and Secrets
4. **Backup Strategy**: Implement database backup procedures
5. **Monitoring**: Set up Prometheus and Grafana
6. **Logging**: Implement centralized logging with ELK stack

## 📝 Additional Resources

- **YouTube Channel**: [LearnWithKASTRO](https://www.youtube.com/@LearnWithKASTRO)
- **LinkedIn**: [kastro-kiran](https://linkedin.com/in/kastro-kiran)
- **WhatsApp Group**: [Join Group](https://chat.whatsapp.com/EGw6ZlwUHZc82cA0vXFnwm?mode=r_c)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Happy Coding! 🚀**