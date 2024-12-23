CREATE DATABASE IF NOT EXISTS dds;

-- Основные факты
CREATE TABLE IF NOT EXISTS dds.fact_orders
(
    id UUID,
    source_address_id UUID,
    target_address_id UUID,
    extra String,
    registered_at DateTime64(3, 'UTC'),
    processed_dttm DateTime64(3, 'UTC')
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(registered_at)
ORDER BY (registered_at, id);

CREATE TABLE IF NOT EXISTS dds.fact_deliveries
(
    pipeline_id UUID,
    cost Decimal64(2),
    estimated_at DateTime64(3, 'UTC'),
    performer_id UUID,
    assigned_at DateTime64(3, 'UTC'),
    released_at DateTime64(3, 'UTC'),
    processed_dttm DateTime64(3, 'UTC')
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(estimated_at)
ORDER BY (estimated_at, pipeline_id);

CREATE TABLE IF NOT EXISTS dds.fact_events
(
    event_id UUID,
    event_type String,
    event_data String,
    event_datetime DateTime64(3, 'UTC'),
    processed_dttm DateTime64(3, 'UTC')
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(event_datetime)
ORDER BY (event_datetime, event_type);

-- Аналитические представления
CREATE MATERIALIZED VIEW IF NOT EXISTS dds.hourly_deliveries_mv
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(hour)
ORDER BY (hour, performer_id)
AS SELECT
    toStartOfHour(estimated_at) as hour,
    performer_id,
    count() as deliveries_count,
    sum(cost) as total_cost,
    avg(cost) as avg_cost,
    count() FILTER (WHERE released_at IS NOT NULL) as completed_count
FROM dds.fact_deliveries
GROUP BY hour, performer_id;

CREATE MATERIALIZED VIEW IF NOT EXISTS dds.hourly_orders_mv
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(hour)
ORDER BY (hour)
AS SELECT
    toStartOfHour(registered_at) as hour,
    count() as orders_count,
    uniqExact(source_address_id) as unique_source_addresses,
    uniqExact(target_address_id) as unique_target_addresses
FROM dds.fact_orders
GROUP BY hour;

CREATE MATERIALIZED VIEW IF NOT EXISTS dds.hourly_events_mv
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(hour)
ORDER BY (hour, event_type)
AS SELECT
    toStartOfHour(event_datetime) as hour,
    event_type,
    count() as events_count
FROM dds.fact_events
GROUP BY hour, event_type;
