-- Need to recreate this table again for every new session
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
    'properties.group.id' = 'flink-sql-orders-high-value',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);

CREATE TABLE IF NOT EXISTS high_value_orders (
    order_id STRING,
    customer_id STRING,
    amount DECIMAL(10, 2),
    event_time TIMESTAMP(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'high_value_orders',
    'properties.bootstrap.servers' = 'redpanda:9092',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);

INSERT INTO high_value_orders
SELECT
    order_id,
    customer_id,
    amount,
    event_time
FROM orders_raw
WHERE amount >= 100.00;