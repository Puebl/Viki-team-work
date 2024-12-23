-- Создаем базу данных MARTS
CREATE DATABASE IF NOT EXISTS marts;

-- Создаем таблицу почасовых продаж
CREATE TABLE IF NOT EXISTS marts.hourly_sales
(
    hour DateTime,
    orders_count UInt32,
    total_amount Decimal(15,2),
    avg_order_amount Decimal(10,2)
)
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(hour)
ORDER BY hour;

-- Создаем таблицу для топ продуктов
CREATE TABLE IF NOT EXISTS marts.top_products
(
    product_id UInt32,
    hour DateTime,
    orders_count UInt32,
    total_revenue Decimal(15,2)
)
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(hour)
ORDER BY (hour, total_revenue DESC);

-- Создаем таблицу для активности клиентов
CREATE TABLE IF NOT EXISTS marts.customer_activity
(
    customer_id UInt32,
    hour DateTime,
    orders_count UInt32,
    total_spent Decimal(15,2),
    avg_order_amount Decimal(10,2)
)
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(hour)
ORDER BY (hour, customer_id);
