#!/bin/sh
set -eu

BROKER="${BROKER:-localhost:9092}"

echo "Creating demo topics on broker: ${BROKER}"

create_topic() {
  topic_name="$1"
  partitions="${2:-3}"
  replicas="${3:-1}"

  echo "Ensuring topic exists: ${topic_name}"
  docker exec flink-demo-redpanda \
    rpk topic create "${topic_name}" \
    --brokers "${BROKER}" \
    --partitions "${partitions}" \
    --replicas "${replicas}" \
    || true
}

create_topic "orders_raw" 3 1
create_topic "orders_by_customer" 3 1

echo
echo "Current topics:"
docker exec flink-demo-redpanda rpk topic list --brokers "${BROKER}"