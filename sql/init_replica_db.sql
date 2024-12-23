-- Создаем таблицу реплики заказов
CREATE TABLE IF NOT EXISTS orders_replica (
    id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    replicated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для оптимизации
CREATE INDEX IF NOT EXISTS idx_replica_date ON orders_replica(order_date);
CREATE INDEX IF NOT EXISTS idx_replica_customer ON orders_replica(customer_id);
CREATE INDEX IF NOT EXISTS idx_replica_product ON orders_replica(product_id);
