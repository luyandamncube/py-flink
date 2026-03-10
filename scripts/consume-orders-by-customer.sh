#!/bin/sh
set -eu

docker exec -it flink-demo-redpanda \
  rpk topic consume orders_by_customer --brokers localhost:9092