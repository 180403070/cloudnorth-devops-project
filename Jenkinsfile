pipeline {
    agent any
    
    environment {
        REGISTRY = "docker.io"
        FRONTEND_IMAGE = "gbayi/cloudnorth-frontend"
        BACKEND_IMAGE = "gbayi/cloudnorth-backend"
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        AWS_CREDENTIALS = credentials('aws-credentials')
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    
    stages {
        // STAGE 1: Code Checkout and Setup
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git branch'
                sh 'echo "Building commit: ${GIT_COMMIT}"'
            }
        }
        
        // STAGE 2: Code Quality Checks
        stage('Code Quality') {
            parallel {
                stage('Frontend Lint') {
                    steps {
                        dir('src/frontend') {
                            sh '''
                                npm install
                                npm run lint || echo "Linting issues found"
                            '''
                        }
                    }
                }
                stage('Backend Lint') {
                    steps {
                        dir('src/backend') {
                            sh '''
                                npm install
                                npm run lint || echo "Linting issues found"
                            '''
                        }
                    }
                }
            }
        }
        
        // STAGE 3: Security Scanning
        stage('Security Scan') {
            steps {
                script {
                    sh 'npm audit --audit-level moderate || true'
                }
            }
        }
        
        // STAGE 4: Build Docker Images
        stage('Build Images') {
            parallel {
                stage('Build Frontend') {
                    steps {
                        dir('src/frontend') {
                            sh '''
                                docker build -t ${FRONTEND_IMAGE}:${BUILD_NUMBER} .
                                docker tag ${FRONTEND_IMAGE}:${BUILD_NUMBER} ${FRONTEND_IMAGE}:latest
                            '''
                        }
                    }
                }
                stage('Build Backend') {
                    steps {
                        dir('src/backend') {
                            sh '''
                                docker build -t ${BACKEND_IMAGE}:${BUILD_NUMBER} .
                                docker tag ${BACKEND_IMAGE}:${BUILD_NUMBER} ${BACKEND_IMAGE}:latest
                            '''
                        }
                    }
                }
            }
        }
        
        // STAGE 5: Test Containers
stage('Container Tests') {
    steps {
        sh '''
            # Test backend container - use port 33000 instead of 3000
            docker run -d --name backend-test -p 33000:3000 ${BACKEND_IMAGE}:${BUILD_NUMBER}
            sleep 10
            curl -f http://localhost:33000/api/health || exit 1
            docker stop backend-test
            docker rm backend-test
            
            # Test frontend container - use port 8800 instead of 8080
            docker run -d --name frontend-test -p 8800:80 ${FRONTEND_IMAGE}:${BUILD_NUMBER}
            sleep 5
            curl -f http://localhost:8800 || exit 1
            docker stop frontend-test
            docker rm frontend-test
        '''
    }
}
        
        // STAGE 6: Push to Registry
        stage('Push to Docker Hub') {
            when {
                branch 'main'
            }
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                            docker push ${FRONTEND_IMAGE}:${BUILD_NUMBER}
                            docker push ${FRONTEND_IMAGE}:latest
                            docker push ${BACKEND_IMAGE}:${BUILD_NUMBER}
                            docker push ${BACKEND_IMAGE}:latest
                        '''
                    }
                }
            }
        }
        
        // STAGE 7: Deploy to Staging
        stage('Deploy to Staging') {
            when {
                branch 'main'
            }
            steps {
                withCredentials([aws(
                    credentialsId: 'aws-credentials',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    dir('terraform') {
                        sh '''
                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                            
                            terraform init -upgrade
                            terraform workspace select staging || terraform workspace new staging
                            terraform plan -var="environment=staging" -var="frontend_image=${FRONTEND_IMAGE}:${BUILD_NUMBER}" -var="backend_image=${BACKEND_IMAGE}:${BUILD_NUMBER}"
                            terraform apply -auto-approve -var="environment=staging" -var="frontend_image=${FRONTEND_IMAGE}:${BUILD_NUMBER}" -var="backend_image=${BACKEND_IMAGE}:${BUILD_NUMBER}"
                        '''
                    }
                }
            }
        }
        
        // STAGE 8: Integration Tests
        stage('Integration Tests') {
            when {
                branch 'main'
            }
            steps {
                script {
                    dir('terraform') {
                        sh '''
                            ALB_DNS=$(terraform output -raw alb_dns_name)
                            echo "Running tests against: $ALB_DNS"
                            curl -f http://$ALB_DNS/api/health || exit 1
                            curl -f http://$ALB_DNS/ || exit 1
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker system prune -f || true'
            cleanWs()
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
} 