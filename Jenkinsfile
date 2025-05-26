pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        EKS_CLUSTER_NAME = 'EKSCICDonlineboutique'
        AWS_ACCOUNT_ID = '123456789012' // <-- Replace with your AWS Account ID
        ECR_BASE = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/PGTO67/microservices-demo.git'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_BASE
                '''
            }
        }

        stage('Build and Push Images') {
            steps {
                script {
                    def services = ['productcatalogservice', 'recommendationservice', 'frontend']
                    for (svc in services) {
                        sh """
                            cd src/${svc}
                            docker build -t $ECR_BASE/${svc}:$IMAGE_TAG .
                            docker push $ECR_BASE/${svc}:$IMAGE_TAG
                            cd -
                        """
                    }
                }
            }
        }

        stage('Update Kubeconfig') {
            steps {
                sh '''
                    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    // Replace images in manifest files with latest tag (optional)
                    sh '''
                        for svc in productcatalogservice recommendationservice frontend; do
                          sed -i "s|IMAGE_PLACEHOLDER|$ECR_BASE/$svc:$IMAGE_TAG|g" k8s/$svc-deployment.yaml
                          kubectl apply -f k8s/$svc-deployment.yaml
                        done
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD pipeline completed successfully!"
        }
        failure {
            echo "❌ CI/CD pipeline failed!"
        }
    }
}
