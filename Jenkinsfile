pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-2'
    }

    stages {
        stage('Clone') {
            steps {
                git branch: 'main', url: 'https://github.com/PGTO67/microservices-demo.git'
            }
        }

        stage('Build') {
            steps {
                echo 'Build container images here'
                // For example: sh './build-all.sh'
            }
        }

        stage('Push to ECR') {
            steps {
                echo 'Push images to ECR'
                // Use `aws ecr get-login-password` + `docker push`
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo 'Deploying to EKS cluster...'
                sh 'kubectl get nodes'
                // Example: sh 'kubectl apply -f kubernetes-manifests/'
            }
        }
    }
}
