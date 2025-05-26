pipeline {
    agent any

    environment {
        ECR_REPO = '982105689473.dkr.ecr.us-east-2.amazonaws.com/your-ecr-repo-name'
        IMAGE_TAG = '1'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
                          userRemoteConfigs: [[url: 'https://github.com/PGTO67/microservices-demo.git']]])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Update the path here if your Dockerfile is not at repo root
                    sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ./docker"
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    sh '''
                    aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 982105689473.dkr.ecr.us-east-2.amazonaws.com
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo 'Deploying to EKS...'
                // Your kubectl deploy commands here
            }
        }
    }
}
