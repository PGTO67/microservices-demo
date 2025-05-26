pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        ECR_ACCOUNT_ID = '982105689473'  // Your AWS Account ID
        ECR_REPO_NAME = 'your-ecr-repo-name' // Change to your repo
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout([$class: 'GitSCM',
                    branches: [[name: 'refs/heads/main']],
                    userRemoteConfigs: [[url: 'git@github.com:your_org/your_repo.git']]
                ])
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    dockerImage.push()
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    sh '''
                    kubectl --kubeconfig ${KUBECONFIG} set image deployment/your-deployment-name your-container-name=${ECR_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    kubectl --kubeconfig ${KUBECONFIG} rollout status deployment/your-deployment-name
                    '''
                }
            }
        }
    }
}
