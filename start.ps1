# Start minikube
minikube start --driver=docker

kubectl cluster-info --context minikube

cd terraform
terraform init
terraform apply -auto-approve
cd ..

kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-single-node.yaml -n kafka

docker build -t postgres-producer:local ./src/producer
minikube image load postgres-producer:local
kubectl apply -f k8s/producer-deployment.yaml