# Flink Concepts

## What Flink is

Apache Flink is a distributed stream processing engine designed for continuous, stateful computation over event streams.

In simple terms:

- Redpanda/Kafka stores the events
- Flink reads those events continuously
- Flink computes live results
- Flink keeps state for aggregations and windows
- Flink checkpoints that state for recovery


Core mental model

A useful mental model is:
```text
stream in -> stateful processing -> continuous result out
```
Unlike batch systems, Flink does not wait for a full dataset to arrive. It processes events as they come in.


## Streams

A stream is an unbounded sequence of events.

In this demo:
- orders_raw is a stream of order events

Example event:
```bash
{
  "order_id": "o-1234abcd",
  "customer_id": "c-003",
  "product_id": "p-200",
  "amount": 142.50,
  "region": "london",
  "event_time": "2026-03-10T13:00:15.123Z"
}
```

## Tables over streams

Flink SQL lets us treat streams as tables.

That means a Kafka topic can become a SQL source table, and another Kafka topic can become a SQL sink table.

Example:
- source topic: orders_raw
- source table: orders_raw
- sink topic: orders_by_customer
- sink table: orders_by_customer

This is one of the easiest ways to understand Flink for analytics users.


## Stateful processing

Many analytics queries require memory of previous events.

Examples:
- count orders by customer
- sum revenue by region
- keep latest event timestamp per key

Flink stores this memory as state.

Without state, Flink could only do stateless transformations like filtering or mapping.


## Keyed state

When a query groups by a key, Flink partitions the work by that key.

Example:
`GROUP BY customer_id`

Flink keeps separate state for each customer.

That allows it to continuously update:
- order count
- total amount
- latest event time


## Event time

Event time is the time the event actually happened.

This is different from processing time, which is when Flink receives the event.

For analytics, event time is usually more meaningful because data can arrive late or out of order.

In this demo, each event contains:
- event_time


##Watermarks

A watermark tells Flink how far it believes event time has progressed.

This helps Flink decide when a time window is complete.

Example:
`WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND`

This means Flink allows a small amount of lateness before finalizing results for a window.


## Windows

Windows let Flink group streaming data into time buckets.

Examples:
- orders per minute
- revenue per hour
- events per 5-minute interval

This demo uses a tumbling window example for revenue by region.

A tumbling window is:
- fixed size
- non-overlapping
- repeated continuously


## Aggregations

Aggregations compute summary values over a stream.

Examples:
- COUNT(*)
- SUM(amount)
- MAX(event_time)

In streaming systems, aggregations are not one-off calculations. They update continuously as new events arrive.


## Source and sink tables

A source table reads data into Flink.

A sink table writes data out of Flink.

Examples in this demo:

Source:
- orders_raw

Sinks:
- orders_by_customer
- high_value_orders
- revenue_by_region_window
- orders_print
- orders_filesystem


## Checkpoints

Checkpoints are snapshots of Flink state.

They allow Flink to recover a stateful job after failure.

Why they matter:
- stateful jobs need durable recovery
- long-running analytics jobs must not lose all progress
- recovery should restart from a recent consistent point

In this demo, checkpoints are stored in MinIO.


## Savepoints

Savepoints are similar to checkpoints, but are typically created manually for controlled stop/restart or migration scenarios.

A simple distinction:
- checkpoints = automatic recovery snapshots
- savepoints = operator-controlled restart or migration snapshots


## Exactly-once processing

Exactly-once means Flink aims to process events and produce results without duplicates or loss after failures.

This relies on:
- state management
- checkpointing
- compatible sinks and sources

For analytics, this matters when correctness is important.


## JobManager vs TaskManager

JobManager
Responsible for:
- accepting submitted jobs
- coordinating execution
- managing checkpoints
- exposing the web UI

TaskManager
Responsible for:
- executing operators
- processing stream partitions
- holding runtime task state

Simple view:
- JobManager = coordinator
- TaskManager = worker


## SQL Client

The SQL Client is used to submit Flink SQL jobs.

In this demo it is how the SQL scenarios are launched.

Important note for this repo:
- separate sql-client.sh -f ... runs do not share temporary table definitions
- each runnable SQL file is therefore self-contained


## Connectors

Connectors allow Flink to integrate with external systems.

In this demo the important ones are:
- Kafka connector
- S3 filesystem connector
- filesystem sink
- print sink

Without the correct connector jars, Flink SQL cannot read or write those external systems.


## Why Flink is interesting for analytics

Flink becomes compelling when the problem requires:
- continuous ingestion
- continuously updated results
- grouped aggregations over streams
- time-based windows
- reliable stateful computation
- fault-tolerant recovery

That is why it is often evaluated for operational analytics and real-time data products.


## Demo-specific examples

Main aggregation
Question:
- how many orders has each customer placed?
- what is their total spend?

Concepts:
- keyed state
- aggregation
- sink topic output

High-value filtering
Question:
- which orders are above a threshold?

Concepts:
- stateless filtering
- stream transformation

Windowed revenue by region
Question:
- what was revenue per region per minute?

Concepts:
- event time
- watermarks
- tumbling windows
- grouped window aggregation

Print sink
Question:
- is Flink reading the stream correctly?

Concepts:
- debugging sink
- fast validation

Filesystem sink
Question:
- can Flink materialize stream results into files?

Concepts:
- sink to storage
- stepping stone toward data-lake style outputs


## Summary

The simplest way to think about Flink in this demo is:

Flink continuously reads events, keeps state while computing live analytics, checkpoints that state for recovery, and writes updated results out to downstream systems.

That is the core concept behind the whole evaluation.