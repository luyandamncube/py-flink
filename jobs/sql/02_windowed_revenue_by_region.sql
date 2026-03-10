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
    'properties.group.id' = 'flink-sql-orders-windowed-region',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.ignore-parse-errors' = 'true'
);

CREATE TABLE IF NOT EXISTS revenue_by_region_window (
    window_start TIMESTAMP(3),
    window_end TIMESTAMP(3),
    region STRING,
    order_count BIGINT,
    total_amount DECIMAL(18, 2),
    PRIMARY KEY (window_start, window_end, region) NOT ENFORCED
) WITH (
    'connector' = 'upsert-kafka',
    'topic' = 'revenue_by_region_window',
    'properties.bootstrap.servers' = 'redpanda:9092',
    'key.format' = 'json',
    'value.format' = 'json',
    'value.json.fail-on-missing-field' = 'false',
    'value.json.ignore-parse-errors' = 'true'
);

INSERT INTO revenue_by_region_window
SELECT
    window_start,
    window_end,
    region,
    COUNT(*) AS order_count,
    CAST(SUM(amount) AS DECIMAL(18, 2)) AS total_amount
FROM TABLE(
    TUMBLE(TABLE orders_raw, DESCRIPTOR(event_time), INTERVAL '1' MINUTE)
)
GROUP BY
    window_start,
    window_end,
    region;