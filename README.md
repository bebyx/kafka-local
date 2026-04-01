# Kafka Local Data Pipeline

## Overview

This project implements a simple end-to-end data pipeline:

* Data is written into **PostgreSQL**
* A **producer service** reads data and sends it to Kafka
* A **consumer service** reads from Kafka and writes data to **MinIO (S3-compatible storage)**

The system is deployed locally on Kubernetes using:

* Minikube
* Strimzi (Kafka operator)
* Helm charts (Postgres, MinIO)

---

## Architecture

```
PostgreSQL
   ↓
Producer (Python)
   ↓
Kafka (Strimzi)
   ↓
Consumer (Python)
   ↓
MinIO (S3)
```

See `guidelines.md` for production considerations.

---

## Components

### PostgreSQL

* Stores source data
* Initialized with database `appdb`
* Table: `test(id, value)`

### Kafka (Strimzi)

* Single-node Kafka cluster
* Topic: `events`

### Producer

* Polls PostgreSQL
* Sends new records to Kafka
* Maintains offset via `id`

### Consumer

* Subscribes to Kafka topic
* Writes events as JSON files into MinIO

### MinIO

* S3-compatible storage
* Bucket: `kafka-sink`

---

## Prerequisites

* Kubernetes cluster (Minikube)
* kubectl
* Terraform
* Docker

---

## Quick Start

Run the bootstrap script:

```bash
./start.sh
```

This will:

* Start Minikube (if not running)
* Deploy infrastructure via Terraform
* Deploy Kafka (Strimzi)
* Deploy producer and consumer services

---

## Usage

### Insert test data into PostgreSQL

```bash
kubectl exec -it -n producer postgres-postgresql-0 -- psql -U app -d appdb

INSERT INTO test (value)
VALUES ('hello'), ('world'), ('kafka');
```

---

### Verify Kafka messages

```bash
kubectl exec -it -n kafka my-cluster-dual-role-0 -- bash

bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic events \
  --from-beginning
```

---

### Verify MinIO output

List objects:

```bash
kubectl run mc --rm -it \
  --image=minio/mc \
  --command -- \
  sh -c "mc alias set local http://minio.consumer.svc.cluster.local:9000 minio minio12345 && mc ls --recursive local/kafka-sink/events"
```

Read file:

```bash
kubectl run mc --rm -it \
  --image=minio/mc \
  --command -- \
  sh -c "mc alias set local http://minio.consumer.svc.cluster.local:9000 minio minio12345 && mc cat local/kafka-sink/events/1.json"
```

Expected output:

```json
{"id": 1, "value": "hello"}
```

---

## Design Decisions

### Polling vs CDC

A simple polling approach is used instead of CDC:

* Easier to implement
* No dependency on Debezium
* Sufficient for demo purposes

---

### Message Format

* JSON
* Simple schema: `{id, value}`

---

### Storage Strategy

* Each Kafka message → separate JSON file in MinIO
* Key format: `events/{id}.json`

---

## Limitations

* No schema evolution
* No deduplication
* No exactly-once guarantees
* No partitioning strategy tuning
* No authentication (MinIO/Kafka are open)

---

## Future Improvements

* Use Kafka Connect (JDBC Source / S3 Sink)
* Add schema registry (Avro / Protobuf)
* Implement idempotent producer
* Add retry & DLQ strategy
* Introduce batching for MinIO writes
* Add observability (Prometheus + Grafana)

---

## AI Usage Disclosure

AI tools were used to:

* Accelerate Kubernetes and Terraform setup
* Generate initial templates for services
* Assist with debugging deployment issues
* Provide documentation structure and content suggestions

All code and architecture decisions were reviewed and validated manually.

---
