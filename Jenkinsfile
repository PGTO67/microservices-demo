pipeline {
    agent any

    options {
        timestamps()
        skipStagesAfterUnstable()
    }

    environment {
        AWS_REGION = 'us-east-2'
        EKS_CLUSTER_NAME = 'EKSCICDonlineboutique'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/PGTO67/microservices-demo.git'
            }
        }

        stage('Configure AWS Credentials') {
            steps {
                withCredentials([string(credentialsId: 'aws-account-id', variable: 'AWS_ACCOUNT_ID')]) {
                    script {
                        env.ECR_BASE = "${AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"
                    }
                }
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    set -e
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_BASE
                '''
            }
        }

        stage('Build and Push Images') {
            steps {
                script {
                    def dockerDirs = sh(
                        script: "find src -type f -name Dockerfile -exec dirname {} \\; | sort -u",
                        returnStdout: true
                    ).trim().split('\n')

                    def builds = [:]

                    for (dir in dockerDirs) {
                        def svc = dir.tokenize('/').last()

                        builds[svc] = {
                            echo "🔨 Building and pushing image for service: ${svc}"
                            sh """
                                set -e
                                cd ${dir}
                                DOCKER_BUILDKIT=1 docker build -t $ECR_BASE/${svc}:$IMAGE_TAG --progress=plain .
                                docker push $ECR_BASE/${svc}:$IMAGE_TAG
                            """
                        }
                    }

                    parallel builds
                }
            }
        }

        stage('Update Kubeconfig') {
            steps {
                sh '''
                    set -e
                    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
                '''
            }
        }

        stage('Helm Diff (Preview Changes)') {
            steps {
                sh '''
                    helm repo update
                    helm diff upgrade online-boutique ./helm/online-boutique --namespace default --set global.image.tag=$IMAGE_TAG || true
                '''
            }
        }

        stage('Deploy with Helm') {
            steps {
                sh '''
                    set -e
                    helm upgrade --install online-boutique ./helm/online-boutique \
                        --namespace default \
                        --set global.image.tag=$IMAGE_TAG
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
