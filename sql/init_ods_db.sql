CREATE SCHEMA IF NOT EXISTS ods;

CREATE TABLE IF NOT EXISTS ods.orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    load_timestamp TIMESTAMP NOT NULL,
    is_valid BOOLEAN DEFAULT true,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31'::TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ods.events (
    event_id VARCHAR(50) PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB NOT NULL,
    event_timestamp TIMESTAMP NOT NULL,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_valid BOOLEAN DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_ods_date ON ods.orders(order_date);
CREATE INDEX IF NOT EXISTS idx_ods_load ON ods.orders(load_timestamp);
CREATE INDEX IF NOT EXISTS idx_ods_valid ON ods.orders(is_valid);

CREATE INDEX IF NOT EXISTS idx_events_type ON ods.events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_timestamp ON ods.events(event_timestamp);
CREATE INDEX IF NOT EXISTS idx_events_data ON ods.events USING gin(event_data);
