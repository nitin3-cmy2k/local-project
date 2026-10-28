pipeline {
    agent any

    environment {
        // Replace with your Docker Hub username
        DOCKER_REGISTRY_USER = 'nitin3cmy2k'
        DOCKER_HUB_USER= 'nitin3cmy2k'
        DOCKER_HUB_PASSWORD = 'shivshakti@#2026' 
        FRONTEND_IMAGE       = 'frontend'
        IMAGE_TAG            = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Pulls code from your Git repository
                checkout scm
            }
        }

        stage('Build Frontend Image') {
            steps {
                script {
                    echo 'Building Frontend Docker Image...'
                    // Assumes a Dockerfile exists in your frontend directory
                    sh "docker build -t ${DOCKER_REGISTRY_USER}/${FRONTEND_IMAGE}:${IMAGE_TAG} ."
                    sh "docker tag ${DOCKER_REGISTRY_USER}/${FRONTEND_IMAGE}:${IMAGE_TAG} ${DOCKER_REGISTRY_USER}/${FRONTEND_IMAGE}:latest"
                }
            }
        }

        stage('Push to Registry') {
            steps {
                script {
                    echo 'Logging into Docker Hub and pushing images...'
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USER')]) {
                        sh "echo ${DOCKER_HUB_PASSWORD} | docker login -u ${DOCKER_HUB_USER} --password-stdin"
                        sh "docker push ${DOCKER_REGISTRY_USER}/${FRONTEND_IMAGE}:${IMAGE_TAG}"
                        sh "docker push ${DOCKER_REGISTRY_USER}/${FRONTEND_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying to VirtualBox Kubernetes Cluster...'
                    
                    // 1. Deploy the MySQL Database
                    sh "kubectl apply -f mysql-deployment.yaml"
                    
                    // 2. Update the frontend manifest dynamically with the new image tag and deploy
                    sh "sed -i 's|${DOCKER_REGISTRY_USER}/${FRONTEND_IMAGE}:latest|${DOCKER_REGISTRY_USER}/${FRONTEND_IMAGE}:${IMAGE_TAG}|g' frontend-deployment.yaml"
                    sh "kubectl apply -f frontend-deployment.yaml"
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                sh "kubectl get pods"
                sh "kubectl get services"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up local Docker images...'
            sh "docker rmi ${DOCKER_REGISTRY_USER}/${FRONTEND_IMAGE}:${IMAGE_TAG} || true"
            sh "docker rmi ${DOCKER_REGISTRY_USER}/${FRONTEND_IMAGE}:latest || true"
        }
    }
}

