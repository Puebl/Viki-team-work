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

CREATE INDEX IF NOT EXISTS idx_ods_date ON ods.orders(order_date);
CREATE INDEX IF NOT EXISTS idx_ods_load ON ods.orders(load_timestamp);
CREATE INDEX IF NOT EXISTS idx_ods_valid ON ods.orders(is_valid);
