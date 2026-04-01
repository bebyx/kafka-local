# Start minikube
minikube start --driver=docker

kubectl cluster-info --context minikube

terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve

kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-single-node.yaml -n kafka

docker build -t postgres-producer:local ./src/producer
minikube image load postgres-producer:local
kubectl apply -f k8s/producer-deployment.yaml

docker build -t kafka-minio-consumer:local ./src/consumer
minikube image load kafka-minio-consumer:local
kubectl apply -f k8s/consumer-deployment.yaml
