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

        if [ -f kubernetes-manifests/kustomization.yaml ]; then
          echo ">>> kustomization.yaml found — using 'kubectl apply -k kubernetes-manifests/'"
          kubectl --kubeconfig "$KUBECONFIG" apply -k kubernetes-manifests/
        else
          echo ">>> No kustomization.yaml — using 'kubectl apply -f kubernetes-manifests/'"
          kubectl --kubeconfig "$KUBECONFIG" apply -f kubernetes-manifests/
        fi

        echo ">>> Current pods across all namespaces:"
        kubectl --kubeconfig "$KUBECONFIG" get pods -A
        '''
      }
    }

    stage('Post-Deploy Info') {
      steps {
        script {
          echo ">>> Fetching Online Boutique LoadBalancer URL..."

          def lb = sh(
            script: "kubectl --kubeconfig '${KUBECONFIG}' get service frontend-external -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'",
            returnStdout: true
          ).trim()

          echo "==============================================="
          echo " Online Boutique deployment finished!"
          echo " Application URL:"
          echo " http://${lb}"
          echo "==============================================="
        }
      }
    }
  }
}

