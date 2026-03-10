CREATE TABLE IF NOT EXISTS orders_raw (
    order_id STRING,
    customer_id STRING,
    product_id STRING,
    amount DECIMAL(10, 2),
    region STRING,
    event_time TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'orders_raw',
    'properties.bootstrap.servers' = 'redpanda:9092',
    'properties.group.id' = 'flink-sql-orders-filesystem',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);

CREATE TABLE IF NOT EXISTS orders_filesystem (
    order_id STRING,
    customer_id STRING,
    product_id STRING,
    amount DECIMAL(10, 2),
    region STRING,
    event_time TIMESTAMP(3)
) WITH (
    'connector' = 'filesystem',
    'path' = 'file:///workspace/state/warehouse/orders_filesystem',
    'format' = 'json'
);

INSERT INTO orders_filesystem
SELECT
    order_id,
    customer_id,
    product_id,
    amount,
    region,
    event_time
FROM orders_raw;