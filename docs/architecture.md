# Architecture

## Overview

This demo evaluates Apache Flink for analytics using a small local streaming stack built with Docker.

Core flow:

```text
Python Producer -> Redpanda topic -> Flink SQL job -> Kafka / print / filesystem sink
                                      |
                                      -> checkpoint / savepoint state in MinIO
```     


## Main components
### Redpanda

Kafka-compatible event broker used for source and sink topics.

Examples:
```text
orders_raw

orders_by_customer

high_value_orders

revenue_by_region_window
``` 
### Flink JobManager

Cluster coordinator responsible for:

- job submission

- scheduling

- checkpoint coordination

- web UI

### Flink TaskManager

Worker process responsible for:

- executing operators

- maintaining task state

- processing stream partitions

### Flink SQL Client

Used to submit demo SQL jobs into the running Flink cluster.

### MinIO

S3-compatible object store used for:

- checkpoints

- avepoints

- optional file sink outputs

### Python Producer

Generates synthetic events and publishes them into Redpanda.

## Dataflow in this demo

### Main aggregation path
```text
produce_orders.py
  -> orders_raw
  -> Flink SQL source table: orders_raw
  -> aggregation by customer
  -> orders_by_customer
```

### Other demo paths

`01_high_value_orders.sql`

- filters expensive orders into high_value_orders

`02_windowed_revenue_by_region.sql`

- computes 1-minute tumbling-window revenue by region into revenue_by_region_window

`03_order_counts_by_region.sql`

- aggregates counts and totals by region

`04_print_debug.sql`

- writes stream output to Flink print sink for debugging

`06_filesystem_sink.sql`

- writes output to local filesystem-backed storage

## Runtime layout
Infrastructure config

- `docker-compose.yml` — local stack wiring

`infra/flink/conf/*` — Flink runtime config

`infra/flink/lib/*` — required connector jars

- `infra/minio/init/create-buckets.sh` — MinIO bootstrap

- `infra/redpanda/*` — Redpanda config

Jobs

- `jobs/sql/*` — SQL demo scenarios

- `jobs/java/*` — placeholder for future DataStream / Java jobs

Producers

- `producers/python/src/*` — synthetic event producers

Scripts

- `scripts/up.sh / down.sh` — lifecycle

- `scripts/seed-topics.sh` — topic bootstrap

- `scripts/check-demo.sh` — health checks

- `scripts/consume-orders-by-customer.sh` — sink inspection

- `scripts/download-flink-jars.sh` — connector bootstrap

## Processing model

This demo uses Flink SQL over Kafka-backed tables.

Key ideas:

- Redpanda topics are exposed as Flink source/sink tables

- aggregations are stateful

- event time is used for windowed analytics

- checkpointing persists state to MinIO

- each runnable SQL file is self-contained because SQL client sessions do not share temporary table metadata across separate invocations