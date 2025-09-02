#!/bin/bash

# Create deployment folder
mkdir -p k8s-deploy

# AWS Account and Region Info
ACCOUNT_ID="982105689473"
REGION="us-east-2"
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# List of microservices
services=(
  adservice
  cartservice-src
  checkoutservice
  currencyservice
  emailservice
  frontend
  loadgenerator
  paymentservice
  productcatalogservice
  recommendationservice
  shippingservice
  shoppingassistantservice
)

echo "Generating Kubernetes YAML files in ./k8s-deploy/"

# Loop through each service and generate deployment + service YAML
for service in "${services[@]}"; do

  # Use ClusterIP for all except frontend
  if [[ "$service" == "frontend" ]]; then
    svc_type="LoadBalancer"
    port=80
    target_port=8080
  else
    svc_type="ClusterIP"
    port=80
    target_port=80
  fi

  cat > k8s-deploy/${service}.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${service}
  labels:
    app: ${service}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${service}
  template:
    metadata:
      labels:
        app: ${service}
    spec:
      containers:
      - name: ${service}
        image: ${ECR_URI}/${service}:latest
        ports:
        - containerPort: ${target_port}

---
apiVersion: v1
kind: Service
metadata:
  name: ${service}
spec:
  selector:
    app: ${service}
  type: ${svc_type}
  ports:
  - protocol: TCP
    port: ${port}
    targetPort: ${target_port}
EOF

done

echo "✅ All YAML files created in ./k8s-deploy/"

