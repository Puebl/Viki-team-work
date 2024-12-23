-- Создаем публикацию для таблицы orders
CREATE PUBLICATION orders_pub FOR TABLE orders;

-- Даем права на репликацию
GRANT ALL PRIVILEGES ON DATABASE source_db TO dwh_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dwh_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO dwh_user;

-- Даем права на репликацию
ALTER ROLE dwh_user WITH REPLICATION;
