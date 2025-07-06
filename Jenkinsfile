pipeline {
    agent any
    
    environment {
        DOCKER_HUB_REPO = "kastrov"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        AWS_REGION = "us-east-1"
        EKS_CLUSTER_NAME = "kastro-eks"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/KastroVKiran/ticket-app-kastro.git'
            }
        }
        
        stage('Build and Push Images') {
            parallel {
                stage('User Service') {
                    steps {
                        script {
                            dir('user-service') {
                                def image = docker.build("${DOCKER_HUB_REPO}/user-service:${BUILD_NUMBER}")
                                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                                    image.push()
                                    image.push('latest')
                                }
                            }
                        }
                    }
                }
                
                stage('Movie Service') {
                    steps {
                        script {
                            dir('movie-service') {
                                def image = docker.build("${DOCKER_HUB_REPO}/movie-service:${BUILD_NUMBER}")
                                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                                    image.push()
                                    image.push('latest')
                                }
                            }
                        }
                    }
                }
                
                stage('Theater Service') {
                    steps {
                        script {
                            dir('theater-service') {
                                def image = docker.build("${DOCKER_HUB_REPO}/theater-service:${BUILD_NUMBER}")
                                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                                    image.push()
                                    image.push('latest')
                                }
                            }
                        }
                    }
                }
                
                stage('Booking Service') {
                    steps {
                        script {
                            dir('booking-service') {
                                def image = docker.build("${DOCKER_HUB_REPO}/booking-service:${BUILD_NUMBER}")
                                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                                    image.push()
                                    image.push('latest')
                                }
                            }
                        }
                    }
                }
                
                stage('Payment Service') {
                    steps {
                        script {
                            dir('payment-service') {
                                def image = docker.build("${DOCKER_HUB_REPO}/payment-service:${BUILD_NUMBER}")
                                docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                                    image.push()
                                    image.push('latest')
                                }
                            }
                        }
                    }
                }
            }
        }
        
        stage('Setup EKS and Install Ingress Controller') {
            steps {
                script {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                        credentialsId: 'aws-creds', 
                                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            # Update kubeconfig
                            aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
                            
                            # Check if ingress controller is already installed
                            if ! kubectl get namespace ingress-nginx >/dev/null 2>&1; then
                                echo "Installing NGINX Ingress Controller..."
                                kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/aws/deploy.yaml
                                
                                # Wait for ingress controller to be ready
                                echo "Waiting for ingress controller to be ready..."
                                kubectl wait --namespace ingress-nginx \
                                  --for=condition=ready pod \
                                  --selector=app.kubernetes.io/component=controller \
                                  --timeout=300s
                            else
                                echo "NGINX Ingress Controller already installed"
                            fi
                        """
                    }
                }
            }
        }
        
        stage('Clean Previous Deployment') {
            steps {
                script {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                        credentialsId: 'aws-creds', 
                                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            echo "Cleaning up previous deployment..."
                            
                            # Delete conflicting ingress from default namespace
                            kubectl delete ingress microservices-ingress --ignore-not-found=true
                            
                            # Delete existing deployments in moviebox namespace
                            kubectl delete deployment user-service payment-service booking-service movie-service mongo -n moviebox --ignore-not-found=true
                            kubectl delete ingress moviebox-ingress -n moviebox --ignore-not-found=true
                            
                            # Wait for cleanup
                            sleep 15
                            
                            echo "Cleanup completed"
                        """
                    }
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                        credentialsId: 'aws-creds', 
                                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            # Update image tags in deployment files
                            sed -i 's|kastrov/user-service:latest|kastrov/user-service:${BUILD_NUMBER}|g\' k8s/user-service-deployment.yaml
                            sed -i 's|kastrov/movie-service:latest|kastrov/movie-service:${BUILD_NUMBER}|g\' k8s/movie-service-deployment.yaml
                            sed -i 's|kastrov/theater-service:latest|kastrov/theater-service:${BUILD_NUMBER}|g\' k8s/theater-service-deployment.yaml
                            sed -i 's|kastrov/booking-service:latest|kastrov/booking-service:${BUILD_NUMBER}|g\' k8s/booking-service-deployment.yaml
                            sed -i 's|kastrov/payment-service:latest|kastrov/payment-service:${BUILD_NUMBER}|g\' k8s/payment-service-deployment.yaml
                            
                            # Step 1: Create namespace
                            echo "Creating namespace..."
                            kubectl apply -f k8s/namespace.yaml
                            sleep 5
                            
                            # Step 2: Deploy MongoDB
                            echo "Deploying MongoDB..."
                            kubectl apply -f k8s/mongodb-deployment.yaml
                            
                            # Wait for MongoDB deployment to be available
                            echo "Waiting for MongoDB deployment..."
                            kubectl wait --for=condition=available deployment/mongo -n moviebox --timeout=180s
                            
                            # Step 3: Deploy microservices
                            echo "Deploying microservices..."
                            kubectl apply -f k8s/user-service-deployment.yaml
                            kubectl apply -f k8s/user-service-service.yaml
                            
                            kubectl apply -f k8s/movie-service-deployment.yaml
                            kubectl apply -f k8s/movie-service-service.yaml
                            
                            kubectl apply -f k8s/theater-service-deployment.yaml
                            kubectl apply -f k8s/theater-service-service.yaml
                            
                            kubectl apply -f k8s/booking-service-deployment.yaml
                            kubectl apply -f k8s/booking-service-service.yaml
                            
                            kubectl apply -f k8s/payment-service-deployment.yaml
                            kubectl apply -f k8s/payment-service-service.yaml
                            
                            # Step 4: Deploy ingress (with retry)
                            echo "Deploying ingress..."
                            for i in {1..3}; do
                                if kubectl apply -f k8s/ingress.yaml; then
                                    echo "Ingress deployed successfully"
                                    break
                                else
                                    echo "Ingress deployment failed, retrying in 10 seconds..."
                                    sleep 10
                                fi
                            done
                            
                            # Wait for all deployments
                            echo "Waiting for all deployments to be available..."
                            kubectl wait --for=condition=available deployment/user-service -n moviebox --timeout=180s
                            kubectl wait --for=condition=available deployment/movie-service -n moviebox --timeout=180s
                            kubectl wait --for=condition=available deployment/theater-service -n moviebox --timeout=180s
                            kubectl wait --for=condition=available deployment/booking-service -n moviebox --timeout=180s
                            kubectl wait --for=condition=available deployment/payment-service -n moviebox --timeout=180s
                            
                            echo "Deployment completed successfully!"
                        """
                    }
                }
            }
        }
        
        stage('Display Access Information') {
            steps {
                script {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                        credentialsId: 'aws-creds', 
                                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            echo ""
                            echo "=========================================="
                            echo "🎬 MOVIEBOX APPLICATION DEPLOYED SUCCESSFULLY! 🎬"
                            echo "=========================================="
                            echo ""
                            
                            # Get LoadBalancer URL
                            LB_URL=\$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}\' 2>/dev/null || echo "")
                            
                            if [ ! -z "\$LB_URL" ]; then
                                echo "🌐 APPLICATION ACCESS URLs:"
                                echo "   Main Application: http://\$LB_URL"
                                echo "   User Service:     http://\$LB_URL/user-service"
                                echo "   Movie Service:    http://\$LB_URL/movie-service"
                                echo "   Theater Service:  http://\$LB_URL/theater-service"
                                echo "   Booking Service:  http://\$LB_URL/booking-service"
                                echo "   Payment Service:  http://\$LB_URL/payment-service"
                                echo "   Admin Dashboard:  http://\$LB_URL/user-service/admin"
                                echo ""
                                echo "👤 USER CREDENTIALS:"
                                echo "   Registration: Create new account at http://\$LB_URL/user-service/register"
                                echo "   Login: Use registered credentials at http://\$LB_URL/user-service/login"
                                echo ""
                                echo "🔧 ADMIN ACCESS:"
                                echo "   Admin Dashboard: http://\$LB_URL/user-service/admin"
                                echo "   (No authentication required for demo)"
                                echo ""
                                echo "🗄️ DATABASE ACCESS COMMANDS:"
                                echo "   # Connect to MongoDB pod"
                                echo "   kubectl exec -it \\\$(kubectl get pods -n moviebox -l app=mongo -o jsonpath='{.items[0].metadata.name}') -n moviebox -- mongosh"
                                echo ""
                                echo "   # Inside MongoDB shell:"
                                echo "   use moviebooking"
                                echo "   show collections"
                                echo "   db.users.find()"
                                echo "   db.bookings.find()"
                                echo "   db.payments.find()"
                                echo ""
                                echo "🎯 QUICK TEST:"
                                echo "   1. Visit: http://\$LB_URL"
                                echo "   2. Register a new user"
                                echo "   3. Browse movies and theaters"
                                echo "   4. Make a booking"
                                echo "   5. Complete payment"
                                echo "   6. Get QR code confirmation"
                                echo ""
                                echo "📱 WHATSAPP GROUP:"
                                echo "   QR Code links to: https://chat.whatsapp.com/EGw6ZlwUHZc82cA0vXFnwm?mode=r_c"
                                echo ""
                                echo "🔗 SOCIAL LINKS:"
                                echo "   YouTube: https://www.youtube.com/@LearnWithKASTRO"
                                echo "   LinkedIn: https://linkedin.com/in/kastro-kiran"
                                echo ""
                                echo "📋 COPY THIS URL TO ACCESS YOUR APP:"
                                echo "   http://\$LB_URL"
                                echo ""
                            else
                                echo "⚠️  LoadBalancer URL not yet available. Please wait a few minutes and run:"
                                echo "   kubectl get svc ingress-nginx-controller -n ingress-nginx"
                            fi
                            
                            echo "📊 DEPLOYMENT STATUS:"
                            kubectl get pods -n moviebox
                            echo ""
                            kubectl get services -n moviebox
                            echo ""
                            kubectl get ingress -n moviebox
                            echo ""
                            echo "=========================================="
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo '✅ DEPLOYMENT SUCCESSFUL!'
            echo 'Your MovieBox application is now live and accessible!'
            echo 'Check the URLs above to access your application.'
        }
        failure {
            echo '❌ DEPLOYMENT FAILED!'
            script {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                    credentialsId: 'aws-creds', 
                                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh """
                        echo "=== Debug Information ==="
                        kubectl get pods -n moviebox
                        echo ""
                        kubectl get events -n moviebox --sort-by='.lastTimestamp' | tail -10
                        echo ""
                        echo "=== Ingress Status ==="
                        kubectl get ingress -A
                        echo ""
                        echo "=== LoadBalancer Status ==="
                        kubectl get svc ingress-nginx-controller -n ingress-nginx
                    """
                }
            }
        }
    }
}
