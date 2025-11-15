pipeline {
  agent any

  environment {
    AWS_REGION   = "us-east-2"
    CLUSTER_NAME = "online-boutique"
    // Use a kubeconfig file in the workspace so it works for the Jenkins user
    KUBECONFIG   = "${env.WORKSPACE}/kubeconfig"
  }

  stages {
    stage('Checkout') {
      steps {
        // Jenkins will use the SCM config from the job
        checkout scm
      }
    }

    stage('Configure kubectl') {
      steps {
        sh '''
        echo ">>> Updating kubeconfig for EKS cluster $CLUSTER_NAME in $AWS_REGION"

        aws eks update-kubeconfig \
          --region $AWS_REGION \
          --name $CLUSTER_NAME \
          --kubeconfig $KUBECONFIG

        echo ">>> Verifying cluster access from Jenkins agent..."
        kubectl --kubeconfig $KUBECONFIG get nodes
        '''
      }
    }

    stage('Deploy microservices app') {
      steps {
        sh '''
        echo ">>> Applying Kubernetes manifests for microservices-demo"

        # Adjust this path if your manifests are somewhere else
        kubectl --kubeconfig $KUBECONFIG apply -f kubernetes-manifests/

        echo ">>> Current pods across all namespaces:"
        kubectl --kubeconfig $KUBECONFIG get pods -A
        '''
      }
    }
  }
}

