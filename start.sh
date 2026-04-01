#!/usr/bin/env bash

set -e

echo "🚀 Starting local Kafka pipeline..."

# 1. Start minikube if not running
if ! minikube status | grep -q "Running"; then
  echo "Starting Minikube..."
  minikube start
fi

# 2. Terraform apply
echo "Applying Terraform..."
terraform init
terraform apply -auto-approve

# 3. Deploy Kafka cluster
echo "Deploying Kafka (Strimzi)..."
kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-single-node.yaml -n kafka

echo "Waiting for Kafka to be ready..."
kubectl wait pod -l strimzi.io/name=my-cluster-kafka -n kafka --for=condition=Ready --timeout=180s || true

# 4. Deploy apps
echo "Deploying producer & consumer..."
kubectl apply -f k8s/producer.yaml
kubectl apply -f k8s/consumer.yaml

echo "✅ Setup completed"
