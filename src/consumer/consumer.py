import os
import json
from kafka import KafkaConsumer
import boto3

KAFKA_BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP", "my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092")
TOPIC = os.getenv("KAFKA_TOPIC", "events")
MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT", "http://minio.consumer.svc.cluster.local:9000")
ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY", "minio")
SECRET_KEY = os.getenv("MINIO_SECRET_KEY", "minio12345")
BUCKET = os.getenv("MINIO_BUCKET", "kafka-sink")

consumer = KafkaConsumer(
    TOPIC,
    bootstrap_servers=KAFKA_BOOTSTRAP,
    value_deserializer=lambda v: json.loads(v.decode("utf-8")),
    auto_offset_reset="earliest",
    enable_auto_commit=True,
    group_id="minio-sink-consumer"
)

s3 = boto3.client(
    "s3",
    endpoint_url=MINIO_ENDPOINT,
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
    region_name="us-east-1",
)

for msg in consumer:
    data = msg.value
    key = f"events/{data['id']}.json"

    s3.put_object(
        Bucket=BUCKET,
        Key=key,
        Body=json.dumps(data).encode("utf-8"),
        ContentType="application/json"
    )

    print(f"Stored {key}: {data}", flush=True)