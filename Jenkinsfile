pipeline {
    agent any
    
    environment {
        DOCKER_HUB_REPO = "kastrov"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/your-repo/movie-booking-app.git'
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
        
        stage('Deploy to EKS') {
            steps {
                script {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                        credentialsId: 'aws-creds', 
                                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh """
                            aws eks update-kubeconfig --region us-east-1 --name kastro-eks
                            
                            # Update image tags
                            sed -i 's|kastrov/user-service:latest|kastrov/user-service:${BUILD_NUMBER}|g\' k8s/user-service-deployment.yaml
                            sed -i 's|kastrov/movie-service:latest|kastrov/movie-service:${BUILD_NUMBER}|g\' k8s/movie-service-deployment.yaml
                            sed -i 's|kastrov/theater-service:latest|kastrov/theater-service:${BUILD_NUMBER}|g\' k8s/theater-service-deployment.yaml
                            sed -i 's|kastrov/booking-service:latest|kastrov/booking-service:${BUILD_NUMBER}|g\' k8s/booking-service-deployment.yaml
                            sed -i 's|kastrov/payment-service:latest|kastrov/payment-service:${BUILD_NUMBER}|g\' k8s/payment-service-deployment.yaml
                            
                            # Apply all configurations
                            kubectl apply -f k8s/
                            
                            # Wait for rollout to complete
                            kubectl rollout status deployment/user-service -n moviebox
                            kubectl rollout status deployment/movie-service -n moviebox
                            kubectl rollout status deployment/theater-service -n moviebox
                            kubectl rollout status deployment/booking-service -n moviebox
                            kubectl rollout status deployment/payment-service -n moviebox
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
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}