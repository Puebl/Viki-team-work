CREATE SCHEMA IF NOT EXISTS replica;

-- Создаем таблицу для репликации
CREATE TABLE IF NOT EXISTS replica.orders (
    id UUID PRIMARY KEY,
    source_address_id UUID NOT NULL,
    target_address_id UUID NOT NULL,
    extra TEXT,
    registered_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Создаем индексы
CREATE INDEX IF NOT EXISTS idx_orders_registered ON replica.orders(registered_at);
CREATE INDEX IF NOT EXISTS idx_orders_addresses ON replica.orders(source_address_id, target_address_id);

-- Создаем подписку на публикацию из основной БД
CREATE SUBSCRIPTION orders_subscription
CONNECTION 'host=postgres_source port=5432 dbname=source_db user=dwh_user password=dwh_password'
PUBLICATION orders_pub
WITH (copy_data = true);
