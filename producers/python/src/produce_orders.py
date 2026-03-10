# producers\python\src\produce_orders.py
import json
import os
import random
import time
import uuid
from datetime import datetime, timezone

from kafka import KafkaProducer


BOOTSTRAP_SERVERS = os.getenv("BOOTSTRAP_SERVERS", "redpanda:9092")
TOPIC = os.getenv("TOPIC", "orders_raw")
SLEEP_SECONDS = float(os.getenv("SLEEP_SECONDS", "1.0"))

CUSTOMERS = ["c-001", "c-002", "c-003", "c-004", "c-005"]
PRODUCTS = ["p-100", "p-200", "p-300", "p-400"]
REGIONS = ["london", "manchester", "birmingham", "bristol"]


def json_serializer(value: dict) -> bytes:
    return json.dumps(value).encode("utf-8")


def build_order_event() -> dict:
    now = datetime.now(timezone.utc)

    return {
        "order_id": f"o-{uuid.uuid4().hex[:8]}",
        "customer_id": random.choice(CUSTOMERS),
        "product_id": random.choice(PRODUCTS),
        "amount": round(random.uniform(5.0, 250.0), 2),
        "region": random.choice(REGIONS),
        "event_time": now.isoformat(timespec="milliseconds").replace("+00:00", "Z"),
    }


def create_producer() -> KafkaProducer:
    return KafkaProducer(
        bootstrap_servers=BOOTSTRAP_SERVERS,
        value_serializer=json_serializer,
        acks="all",
        retries=5,
    )


def main() -> None:
    print(f"Connecting producer to Kafka broker(s): {BOOTSTRAP_SERVERS}")
    print(f"Publishing to topic: {TOPIC}")
    print(f"Sleep interval: {SLEEP_SECONDS} second(s)")

    producer = create_producer()

    try:
        while True:
            event = build_order_event()
            future = producer.send(TOPIC, value=event)
            metadata = future.get(timeout=10)

            print(
                f"published topic={metadata.topic} "
                f"partition={metadata.partition} "
                f"offset={metadata.offset} "
                f"event={event}"
            )

            time.sleep(SLEEP_SECONDS)

    except KeyboardInterrupt:
        print("Producer interrupted, shutting down...")
    finally:
        producer.flush()
        producer.close()


if __name__ == "__main__":
    main()