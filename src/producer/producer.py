import os
import psycopg2
import json
import time
from kafka import KafkaProducer

POSTGRES_HOST = os.getenv("POSTGRES_HOST", "postgres-postgresql.producer.svc.cluster.local")
POSTGRES_DB = os.getenv("POSTGRES_DB", "appdb")
POSTGRES_USER = os.getenv("POSTGRES_USER", "app")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "app")
POSTGRES_PORT = int(os.getenv("POSTGRES_PORT", "5432"))

KAFKA_BOOTSTRAP = os.getenv("KAFKA_BOOTSTRAP", "my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092")
TOPIC = os.getenv("KAFKA_TOPIC", "events")

POLL_INTERVAL = int(os.getenv("POLL_INTERVAL", "5"))

conn = psycopg2.connect(
    host=POSTGRES_HOST,
    database=POSTGRES_DB,
    user=POSTGRES_USER,
    password=POSTGRES_PASSWORD,
    port=POSTGRES_PORT
)

producer = KafkaProducer(
    bootstrap_servers=KAFKA_BOOTSTRAP,
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

last_id = 0

while True:
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT id, value FROM test WHERE id > %s ORDER BY id ASC",
                (last_id,)
            )

            rows = cur.fetchall()

            for row in rows:
                event = {"id": row[0], "value": row[1]}
                producer.send(TOPIC, event)
                last_id = row[0]

            producer.flush()

            if rows:
                print(f"Produced {len(rows)} events, last_id={last_id}", flush=True)

    except Exception as e:
        print(f"Error: {e}", flush=True)
        time.sleep(5)

    time.sleep(POLL_INTERVAL)