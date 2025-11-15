pipeline {
  agent any

  environment {
    AWS_REGION   = "us-east-2"
    CLUSTER_NAME = "online-boutique"
    // Store kubeconfig in the Jenkins workspace
    KUBECONFIG   = "${env.WORKSPACE}/kubeconfig"
  }

  options {
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        // Uses the same SCM config you set in the Jenkins job
        checkout scm
      }
    }

    stage('Configure kubectl') {
      steps {
        sh '''
        echo ">>> Updating kubeconfig for EKS cluster $CLUSTER_NAME in $AWS_REGION"

        aws eks update-kubeconfig \
          --region "$AWS_REGION" \
          --name "$CLUSTER_NAME" \
          --kubeconfig "$KUBECONFIG"

        echo ">>> Verifying cluster access from Jenkins agent..."
        kubectl --kubeconfig "$KUBECONFIG" get nodes
        '''
      }
    }

    stage('Deploy microservices app') {
      steps {
        sh '''
        echo ">>> Applying Kubernetes manifests for microservices-demo"

        # Adjust this path if your manifests are elsewhere
        kubectl --kubeconfig "$KUBECONFIG" apply -f kubernetes-manifests/

        echo ">>> Current pods across all namespaces:"
        kubectl --kubeconfig "$KUBECONFIG" get pods -A
        '''
      }
    }
  }
}

