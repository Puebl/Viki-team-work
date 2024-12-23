# Data Warehouse для System Design проекта

Этот проект реализует хранилище данных (DWH) для основного [System Design проекта](https://github.com/syubogdanov/hse-system-design). DWH обеспечивает аналитическую обработку данных из основной системы.

## Интеграция с основным проектом

DWH интегрируется с основным проектом следующим образом:

1. **Source Data**
   - Основная PostgreSQL база данных из System Design проекта
   - Содержит транзакционные данные о заказах и их выполнении
   - Интегрируется с сервисами `config-stub-http-api` и `performer-stub-http-api`

2. **Kafka Integration**
   - Использует существующую Kafka инфраструктуру для получения событий
   - Отслеживает топики `${TOPIC_NAME_RESULTS}` и `${TOPIC_NAME_TRIGGERS}`
   - Обеспечивает real-time обновление данных в DWH

3. **Prometheus Integration**
   - Использует метрики из Prometheus основного проекта
   - Дополняет их специфичными метриками DWH
   - Визуализирует в Grafana

## Архитектура

Проект состоит из следующих слоев:

1. **Source Layer** (PostgreSQL)
   - Интеграция с основной БД проекта
   - Порт: 5432

2. **Replica Layer** (PostgreSQL)
   - Реплика для снижения нагрузки на основную БД
   - Порт: 5433

3. **ODS Layer** (PostgreSQL)
   - Операционное хранилище
   - Интеграция с Kafka для real-time обновлений
   - Порт: 5434

4. **DDS Layer** (ClickHouse)
   - Детальные данные для аналитики
   - Интеграция с Prometheus метриками
   - Порты: 8123, 9000

5. **MARTS Layer** (ClickHouse)
   - Бизнес-витрины
   - Агрегированные метрики
   - Порты: 8124, 9001

## Анализируемые данные

1. **Заказы и выполнение**
   - Статистика по заказам
   - Время выполнения заказов
   - Эффективность исполнителей

2. **Системные метрики**
   - Производительность API
   - Задержки в обработке
   - Ошибки и отказы

3. **Бизнес-метрики**
   - Конверсия заказов
   - Активность пользователей
   - ROI по типам заказов

## Структура данных

Хранилище данных организовано в виде многоуровневой архитектуры для эффективного анализа и мониторинга системы доставки.

### ODS (Operational Data Store)

Оперативное хранилище данных содержит актуальную информацию о заказах, доставках и исполнителях:

#### Основные таблицы

- **orders** - Информация о заказах
  - `id` - Уникальный идентификатор заказа
  - `source_address_id` - Адрес отправления
  - `target_address_id` - Адрес доставки
  - `registered_at` - Время регистрации заказа
  
- **deliveries** - Информация о доставках
  - `pipeline_id` - ID процесса доставки
  - `cost` - Стоимость доставки
  - `performer_id` - ID курьера
  - `estimated_at` - Время расчета стоимости
  - `assigned_at` - Время назначения курьера
  - `released_at` - Время завершения доставки

- **performers** - Информация о курьерах
  - `id` - Уникальный идентификатор курьера

- **events** - События системы из Kafka
  - `event_id` - ID события
  - `event_type` - Тип события
  - `event_data` - Данные события (JSON)
  - `event_timestamp` - Время события

### DDS (Data Data Store)

Детальное хранилище для аналитики, оптимизированное для быстрых запросов:

#### Таблицы фактов

- **fact_orders** - Факты о заказах
- **fact_deliveries** - Факты о доставках
- **fact_events** - Факты о событиях системы

#### Аналитические представления

- **hourly_deliveries_mv** - Почасовая статистика доставок
  - Количество доставок по курьерам
  - Общая и средняя стоимость
  - Количество завершенных доставок
  
- **hourly_orders_mv** - Почасовая статистика заказов
  - Общее количество заказов
  - Уникальные адреса отправления/доставки
  
- **hourly_events_mv** - Почасовая статистика событий
  - Количество событий по типам

### Примеры аналитических запросов

1. Эффективность курьеров:
```sql
SELECT 
    performer_id,
    count(*) as total_deliveries,
    avg(cost) as avg_delivery_cost,
    avg(extract(epoch from (released_at - assigned_at))) as avg_delivery_time_seconds
FROM dds.fact_deliveries
WHERE released_at IS NOT NULL
GROUP BY performer_id
ORDER BY avg_delivery_time_seconds;
```

2. Популярные маршруты:
```sql
SELECT 
    source_address_id,
    target_address_id,
    count(*) as route_count
FROM dds.fact_orders
GROUP BY source_address_id, target_address_id
ORDER BY route_count DESC
LIMIT 10;
```

3. Статистика по часам:
```sql
SELECT 
    hour,
    orders_count,
    unique_source_addresses,
    unique_target_addresses
FROM dds.hourly_orders_mv
WHERE hour >= now() - INTERVAL '24 HOUR'
ORDER BY hour;
```

### Оптимизация производительности

1. **Партиционирование**:
   - Данные разделены по месяцам для быстрого доступа
   - Автоматическое удаление старых партиций

2. **Индексы**:
   - Оптимизированы для частых запросов
   - Покрывающие индексы для основных сценариев

3. **Материализованные представления**:
   - Автоматическое обновление
   - Предрасчет популярных метрик

## Управление миграциями

Проект использует Alembic для управления миграциями базы данных. Это позволяет:
- Автоматически создавать и обновлять схему базы данных
- Отслеживать изменения в структуре БД
- Откатывать изменения при необходимости

### Структура миграций

Миграции находятся в директории `main_project/migrations/`:
- `versions/` - файлы миграций
- `env.py` - настройки окружения
- `script.py.mako` - шаблон для новых миграций
- `alembic.ini` - конфигурация Alembic

### Модели SQLAlchemy

В файле `main_project/models.py` определены модели:
- `Orders` - заказы
- `Deliveries` - доставки
- `Performers` - исполнители
- `Events` - события системы

### Работа с миграциями

1. Автоматическое создание миграции:
```bash
alembic revision --autogenerate -m "описание изменений"
```

2. Применение миграций:
```bash
alembic upgrade head
```

3. Откат миграций:
```bash
alembic downgrade -1  # откат на одну миграцию назад
```

При использовании Docker Compose миграции применяются автоматически при запуске:
```bash
docker-compose up
```

## Требования

- Docker и Docker Compose
- Основной проект [hse-system-design](https://github.com/syubogdanov/hse-system-design)
- Минимум 8GB RAM
- 20GB свободного места

## Установка и запуск

1. Клонируйте оба репозитория:
```bash
git clone https://github.com/syubogdanov/hse-system-design.git
git clone https://github.com/Puebl/Viki-team-work.git
```

2. Запустите основной проект:
```bash
cd hse-system-design
docker-compose up -d
```

3. Запустите DWH:
```bash
cd ../Viki-team-work
docker-compose up -d
```

## Доступ к компонентам

1. **Airflow** (оркестрация ETL):
   - URL: http://localhost:8080
   - Login: airflow
   - Password: airflow

2. **Grafana** (визуализация):
   - URL: http://localhost:3000
   - Login: admin
   - Password: admin

3. **Kafka UI** (мониторинг событий):
   - URL: http://localhost:8080

4. **Prometheus** (метрики):
   - URL: http://localhost:9090

## Основные дашборды

1. **Операционные метрики**
   - Количество и статусы заказов
   - Время выполнения
   - SLA и отклонения

2. **Технические метрики**
   - Производительность API
   - Kafka лаги
   - Ошибки и исключения

3. **Бизнес-метрики**
   - Динамика заказов
   - Эффективность исполнителей
   - Финансовые показатели

## Troubleshooting

1. Проверка логов:
```bash
docker-compose logs
```

2. Перезапуск сервиса:
```bash
docker-compose restart <service_name>
```

3. Полная переинициализация:
```bash
docker-compose down -v
docker-compose up -d