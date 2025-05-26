pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        EKS_CLUSTER_NAME = 'EKSCICDonlineboutique'
        AWS_ACCOUNT_ID = '123456789012'
        ECR_BASE = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/PGTO67/microservices-demo.git'
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_BASE
                '''
            }
        }

        stage('Build and Push One Image') {
            steps {
                script {
                    // Find first Dockerfile and get its directory
                    def firstDir = sh(
                        script: "find src -type f -name Dockerfile -exec dirname {} \\; | head -n 1",
                        returnStdout: true
                    ).trim()

                    def svc = firstDir.tokenize('/').last()
                    echo "🔨 Building image for service: ${svc}"
                    sh """
                        cd ${firstDir}
                        DOCKER_BUILDKIT=1 docker build -t $ECR_BASE/${svc}:$IMAGE_TAG --progress=plain .
                        docker push $ECR_BASE/${svc}:$IMAGE_TAG
                    """
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

        stage('Deploy with Helm') {
            steps {
                sh '''
                    helm upgrade --install online-boutique ./helm/online-boutique --namespace default --set image.tag=$IMAGE_TAG
                '''
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
