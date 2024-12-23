CREATE DATABASE IF NOT EXISTS dds;

CREATE TABLE IF NOT EXISTS dds.fact_orders
(
    order_id UInt32,
    customer_id UInt32,
    product_id UInt32,
    order_datetime DateTime,
    amount Decimal(10,2),
    status String,
    processed_dttm DateTime
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(order_datetime)
ORDER BY (order_datetime, order_id);

CREATE MATERIALIZED VIEW IF NOT EXISTS dds.hourly_orders_mv
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(hour)
ORDER BY (hour, customer_id)
AS SELECT
    toStartOfHour(order_datetime) as hour,
    customer_id,
    count() as orders_count,
    sum(amount) as total_amount
FROM dds.fact_orders
GROUP BY hour, customer_id;
