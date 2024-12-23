-- Создаем таблицу заказов в источнике
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    order_date TIMESTAMP NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL
);

-- Добавляем индекс по дате для оптимизации выборки
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);

-- Добавляем тестовые данные
INSERT INTO orders (customer_id, product_id, order_date, amount, status)
VALUES 
    (1, 1, NOW() - INTERVAL '30 minutes', 100.50, 'completed'),
    (2, 2, NOW() - INTERVAL '25 minutes', 200.75, 'processing'),
    (1, 3, NOW() - INTERVAL '20 minutes', 150.25, 'completed'),
    (3, 1, NOW() - INTERVAL '15 minutes', 300.00, 'completed'),
    (2, 4, NOW() - INTERVAL '10 minutes', 450.25, 'processing');
