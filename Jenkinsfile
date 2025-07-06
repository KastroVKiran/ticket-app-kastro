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
                            
                            # Get LoadBalancer URL
                            echo "Getting LoadBalancer URL..."
                            kubectl get svc ingress-nginx-controller -n ingress-nginx
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
                            sed -i 's|kastrov/user-service:latest|kastrov/user-service:${BUILD_NUMBER}|g' k8s/user-service-deployment.yaml
                            sed -i 's|kastrov/movie-service:latest|kastrov/movie-service:${BUILD_NUMBER}|g' k8s/movie-service-deployment.yaml
                            sed -i 's|kastrov/theater-service:latest|kastrov/theater-service:${BUILD_NUMBER}|g' k8s/theater-service-deployment.yaml
                            sed -i 's|kastrov/booking-service:latest|kastrov/booking-service:${BUILD_NUMBER}|g' k8s/booking-service-deployment.yaml
                            sed -i 's|kastrov/payment-service:latest|kastrov/payment-service:${BUILD_NUMBER}|g' k8s/payment-service-deployment.yaml
                            
                            # Step 1: Create namespace first
                            echo "Creating namespace..."
                            kubectl apply -f k8s/namespace.yaml
                            
                            # Wait for namespace to be ready
                            kubectl wait --for=condition=Ready namespace/moviebox --timeout=60s
                            
                            # Step 2: Deploy MongoDB first (database dependency)
                            echo "Deploying MongoDB..."
                            kubectl apply -f k8s/mongodb-deployment.yaml
                            
                            # Wait for MongoDB to be ready
                            echo "Waiting for MongoDB to be ready..."
                            kubectl wait --for=condition=ready pod -l app=mongo -n moviebox --timeout=300s
                            
                            # Step 3: Deploy all microservices
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
                            
                            # Step 4: Deploy ingress
                            echo "Deploying ingress..."
                            kubectl apply -f k8s/ingress.yaml
                            
                            # Wait for all deployments to be ready
                            echo "Waiting for all services to be ready..."
                            kubectl wait --for=condition=ready pod -l app=user-service -n moviebox --timeout=300s
                            kubectl wait --for=condition=ready pod -l app=movie-service -n moviebox --timeout=300s
                            kubectl wait --for=condition=ready pod -l app=theater-service -n moviebox --timeout=300s
                            kubectl wait --for=condition=ready pod -l app=booking-service -n moviebox --timeout=300s
                            kubectl wait --for=condition=ready pod -l app=payment-service -n moviebox --timeout=300s
                        """
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                script {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                        credentialsId: 'aws-creds', 
                                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            echo "=== Deployment Status ==="
                            kubectl get pods -n moviebox
                            echo ""
                            echo "=== Services ==="
                            kubectl get services -n moviebox
                            echo ""
                            echo "=== Ingress ==="
                            kubectl get ingress -n moviebox
                            echo ""
                            echo "=== LoadBalancer URL ==="
                            kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
                            echo ""
                            echo ""
                            echo "=== Health Check ==="
                            # Wait a bit for services to be fully ready
                            sleep 30
                            
                            # Get the LoadBalancer URL
                            LB_URL=\$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
                            if [ ! -z "\$LB_URL" ]; then
                                echo "LoadBalancer URL: \$LB_URL"
                                echo "Application will be available at: http://\$LB_URL"
                                echo "Please update your DNS or /etc/hosts file to point moviebox.local to \$LB_URL"
                            else
                                echo "LoadBalancer URL not yet available. Please check later with:"
                                echo "kubectl get svc ingress-nginx-controller -n ingress-nginx"
                            fi
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
            echo '=== DEPLOYMENT SUCCESSFUL ==='
            echo 'Your MovieBox application has been deployed successfully!'
            echo 'Next steps:'
            echo '1. Get the LoadBalancer URL: kubectl get svc ingress-nginx-controller -n ingress-nginx'
            echo '2. Update your DNS or /etc/hosts file to point moviebox.local to the LoadBalancer IP'
            echo '3. Access your application at: http://moviebox.local'
        }
        failure {
            echo '=== DEPLOYMENT FAILED ==='
            echo 'Please check the logs above for error details.'
            script {
                withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                    credentialsId: 'aws-creds', 
                                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh """
                        echo "=== Debug Information ==="
                        kubectl get pods -n moviebox || echo "No pods found in moviebox namespace"
                        kubectl get events -n moviebox --sort-by='.lastTimestamp' || echo "No events found"
                    """
                }
            }
        }
    }
}
