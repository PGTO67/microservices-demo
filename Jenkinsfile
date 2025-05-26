pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        EKS_CLUSTER_NAME = 'EKSCICDonlineboutique'
        AWS_ACCOUNT_ID = '123456789012'  // Replace with your AWS Account ID
        ECR_BASE = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/PGTO67/microservices-demo.git', branch: 'main'
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
                    def dockerDirs = sh(
                        script: "find src -type f -name Dockerfile -exec dirname {} \\;",
                        returnStdout: true
                    ).trim().split('\n')

                    for (dir in dockerDirs) {
                        def svc = dir.tokenize('/').last()
                        sh """
                            cd ${dir}
                            docker build -t $ECR_BASE/${svc}:$IMAGE_TAG .
                            docker push $ECR_BASE/${svc}:$IMAGE_TAG
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

        stage('Deploy with Helm') {
            steps {
                script {
                    def dockerDirs = sh(
                        script: "find src -type f -name Dockerfile -exec dirname {} \\;",
                        returnStdout: true
                    ).trim().split('\n')

                    for (dir in dockerDirs) {
                        def svc = dir.tokenize('/').last()
                        // Assuming helm charts are in a 'helm' directory with service name subfolders
                        sh """
                            helm upgrade --install ${svc} helm/${svc} \
                              --set image.repository=$ECR_BASE/${svc} \
                              --set image.tag=$IMAGE_TAG
                        """
                    }
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
