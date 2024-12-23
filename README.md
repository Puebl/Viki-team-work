# Data Warehouse Project

Проект реализует многослойное хранилище данных (DWH) с использованием современного стека технологий.

## Архитектура

Проект состоит из следующих слоев:

1. **Source Layer** (PostgreSQL)
   - Исходная база данных с транзакционными данными
   - Порт: 5432

2. **Replica Layer** (PostgreSQL)
   - Реплика исходной базы данных
   - Порт: 5433

3. **ODS Layer** (PostgreSQL)
   - Операционное хранилище данных
   - Оптимизировано для OLTP операций
   - Порт: 5434

4. **DDS Layer** (ClickHouse)
   - Детальный слой данных
   - Денормализованные структуры для аналитики
   - Порты: 8123, 9000

5. **MARTS Layer** (ClickHouse)
   - Витрины данных для бизнес-анализа
   - Порты: 8124, 9001

## Компоненты системы

1. **Apache Airflow**
   - Оркестрация ETL процессов
   - Веб-интерфейс: http://localhost:8080
   - DAG запускается каждый час

2. **Grafana**
   - Мониторинг и визуализация
   - Веб-интерфейс: http://localhost:3000
   - Предустановленные дашборды для метрик

## Требования

- Docker и Docker Compose
- Минимум 8GB RAM
- 20GB свободного места на диске

## Установка и запуск

1. Клонируйте репозиторий:
```bash
git clone https://github.com/Puebl/Viki-team-work.git
cd Viki-team-work
```

2. Запустите контейнеры:
```bash
docker-compose up -d
```

3. Проверьте статус контейнеров:
```bash
docker-compose ps
```

## Структура данных

1. **Source/Replica Layer**
   - Таблица orders с исходными данными заказов

2. **ODS Layer**
   - Очищенные данные с дополнительными техническими полями
   - Версионность данных (valid_from, valid_to)
   - Оптимизированные индексы

3. **DDS Layer**
   - Денормализованная таблица fact_orders
   - Партиционирование по дате
   - Материализованные представления

4. **MARTS Layer**
   - Агрегированные данные по часам
   - Основные бизнес-метрики

## Мониторинг

В Grafana настроены следующие метрики:

1. **ETL метрики**
   - Время выполнения каждого этапа
   - Количество обработанных записей
   - Ошибки и отказы

2. **Качество данных**
   - Пропущенные значения
   - Дубликаты
   - Аномалии

3. **Бизнес-метрики**
   - Количество заказов
   - Общая сумма продаж
   - Средний чек
   - Топ продуктов/клиентов

## Доступ к компонентам

1. **Airflow**:
   - URL: http://localhost:8080
   - Login: airflow
   - Password: airflow

2. **Grafana**:
   - URL: http://localhost:3000
   - Login: admin
   - Password: admin

3. **PostgreSQL**:
   - Source DB: localhost:5432
   - Replica DB: localhost:5433
   - ODS DB: localhost:5434
   - User: dwh_user
   - Password: dwh_password

4. **ClickHouse**:
   - DDS: http://localhost:8123
   - MARTS: http://localhost:8124

## Troubleshooting

1. Если контейнеры не запускаются:
```bash
docker-compose logs
```

2. Для перезапуска конкретного сервиса:
```bash
docker-compose restart <service_name>
```

3. Для полной очистки и перезапуска:
```bash
docker-compose down -v
docker-compose up -d