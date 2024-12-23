# Data Warehouse Project

This project implements a multi-layer data warehouse with the following components:

## Architecture Components

- Source PostgreSQL Database
- PostgreSQL Replica
- ODS Layer (PostgreSQL)
- DDS Layer (ClickHouse)
- MARTS Layer (ClickHouse)
- Apache Airflow for orchestration
- Grafana for monitoring

## Setup Instructions

1. Install Docker and Docker Compose
2. Clone this repository
3. Run the following command to start all services:
```bash
docker-compose up -d
```

## Layer Descriptions

1. **Source Layer**: Original PostgreSQL database
2. **ODS (Operational Data Store)**: 
   - OLTP-optimized PostgreSQL database
   - Raw data from source systems
   - Minimal transformations
   
3. **DDS (Data Distribution Service)**:
   - ClickHouse database
   - Normalized and cleaned data
   - Business logic transformations
   
4. **MARTS Layer**:
   - ClickHouse database
   - Aggregated data for specific business domains
   - Optimized for analytical queries

## Monitoring Metrics

The Grafana dashboard includes the following metrics:
- Data volume by layer
- ETL job execution times
- Data freshness
- Error rates

## Access Points

- Airflow UI: http://localhost:8080
- Grafana: http://localhost:3000
- PostgreSQL Main: localhost:5432
- PostgreSQL Replica: localhost:5433
- PostgreSQL ODS: localhost:5434
- ClickHouse DDS: localhost:8123
- ClickHouse MARTS: localhost:8124
