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