import psycopg2
import json
import time
from kafka import KafkaProducer

conn = psycopg2.connect(
    host="postgres-postgresql.producer.svc.cluster.local",
    database="appdb",
    user="app",
    password="app",
    port=5432
)

producer = KafkaProducer(
    bootstrap_servers="my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9092",
    value_serializer=lambda v: json.dumps(v).encode("utf-8")
)

last_id = 0

while True:
    cur = conn.cursor()

    cur.execute(
        "SELECT id, value FROM test WHERE id > %s ORDER BY id ASC",
        (last_id,)
    )

    rows = cur.fetchall()

    for row in rows:
        event = {"id": row[0], "value": row[1]}
        producer.send("events", event)
        last_id = row[0]

    producer.flush()

    time.sleep(5)