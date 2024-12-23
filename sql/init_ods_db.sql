CREATE SCHEMA IF NOT EXISTS ods;

-- Основные таблицы
CREATE TABLE IF NOT EXISTS ods.orders (
    id UUID PRIMARY KEY,
    source_address_id UUID NOT NULL,
    target_address_id UUID NOT NULL,
    extra TEXT,
    registered_at TIMESTAMP WITH TIME ZONE NOT NULL,
    load_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS ods.deliveries (
    pipeline_id UUID PRIMARY KEY,
    cost DECIMAL(10,2),
    estimated_at TIMESTAMP WITH TIME ZONE,
    performer_id UUID,
    assigned_at TIMESTAMP WITH TIME ZONE,
    released_at TIMESTAMP WITH TIME ZONE,
    load_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS ods.performers (
    id UUID PRIMARY KEY,
    load_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT true
);

-- События из Kafka
CREATE TABLE IF NOT EXISTS ods.events (
    event_id UUID PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB NOT NULL,
    event_timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    load_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT true
);

-- Индексы для оптимизации
CREATE INDEX IF NOT EXISTS idx_orders_registered ON ods.orders(registered_at);
CREATE INDEX IF NOT EXISTS idx_orders_addresses ON ods.orders(source_address_id, target_address_id);

CREATE INDEX IF NOT EXISTS idx_deliveries_performer ON ods.deliveries(performer_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_pipeline ON ods.deliveries(pipeline_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_timestamps ON ods.deliveries(estimated_at, assigned_at, released_at);

CREATE INDEX IF NOT EXISTS idx_events_type ON ods.events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_timestamp ON ods.events(event_timestamp);
CREATE INDEX IF NOT EXISTS idx_events_data ON ods.events USING gin(event_data);
