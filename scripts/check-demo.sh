#!/bin/sh
set -eu

echo "Flink jobs:"
curl -s http://localhost:8082/jobs/overview || true
echo

echo "Topics:"
docker exec flink-demo-redpanda rpk topic list --brokers localhost:9092 || true
echo

echo "MinIO buckets:"
docker exec flink-demo-minio-init /bin/sh -c "mc ls local" || true