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
    'properties.group.id' = 'flink-sql-orders',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);

CREATE TABLE IF NOT EXISTS orders_by_customer (
    customer_id STRING,
    order_count BIGINT,
    total_amount DECIMAL(18, 2),
    last_event_time TIMESTAMP(3),
    PRIMARY KEY (customer_id) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'orders_by_customer',
    'properties.bootstrap.servers' = 'redpanda:9092',
    'key.format' = 'json',
    'value.format' = 'json',
    'value.json.fail-on-missing-field' = 'false',
    'value.json.ignore-parse-errors' = 'true'
);

INSERT INTO orders_by_customer
SELECT
    customer_id,
    COUNT(*) AS order_count,
    CAST(SUM(amount) AS DECIMAL(18, 2)) AS total_amount,
    MAX(event_time) AS last_event_time
FROM orders_raw
GROUP BY customer_id;