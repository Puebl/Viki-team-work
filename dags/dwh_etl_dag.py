from datetime import datetime, timedelta
import os
import json
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.hooks.postgres_hook import PostgresHook
from airflow.providers.clickhouse.operators.clickhouse import ClickHouseOperator
from airflow.providers.clickhouse.hooks.clickhouse import ClickHouseHook
from kafka import KafkaConsumer

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 12, 23),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'dwh_etl_pipeline',
    default_args=default_args,
    description='ETL pipeline for DWH',
    schedule_interval=timedelta(hours=1),
)

def process_kafka_events(**kwargs):
    consumer = KafkaConsumer(
        os.environ.get('TOPIC_NAME_RESULTS', 'results'),
        bootstrap_servers=os.environ.get('KAFKA_BROKER', 'kafka:9092'),
        auto_offset_reset='earliest',
        enable_auto_commit=True,
        group_id='dwh_consumer_group',
        value_deserializer=lambda x: json.loads(x.decode('utf-8'))
    )

    ods_hook = PostgresHook(postgres_conn_id='postgres_ods')
    
    for message in consumer:
        event_data = message.value
        ods_hook.run("""
            INSERT INTO ods.events (
                event_id, 
                event_type, 
                event_data, 
                event_timestamp
            ) VALUES (
                %(event_id)s,
                %(event_type)s,
                %(event_data)s,
                %(event_timestamp)s
            )
        """, parameters={
            'event_id': event_data.get('id'),
            'event_type': event_data.get('type'),
            'event_data': json.dumps(event_data),
            'event_timestamp': datetime.fromtimestamp(message.timestamp/1000.0)
        })

def process_source_data(**kwargs):
    source_hook = PostgresHook(postgres_conn_id='postgres_source')
    replica_hook = PostgresHook(postgres_conn_id='postgres_replica')
    
    source_data = source_hook.get_records("""
        SELECT id, customer_id, product_id, order_date, amount, status
        FROM orders
        WHERE order_date >= NOW() - INTERVAL '1 hour'
    """)
    
    for record in source_data:
        replica_hook.run("""
            INSERT INTO orders_replica (id, customer_id, product_id, order_date, amount, status)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON CONFLICT (id) DO UPDATE 
            SET customer_id = EXCLUDED.customer_id,
                product_id = EXCLUDED.product_id,
                order_date = EXCLUDED.order_date,
                amount = EXCLUDED.amount,
                status = EXCLUDED.status
        """, parameters=record)
    
    return len(source_data)

def load_to_ods(**kwargs):
    replica_hook = PostgresHook(postgres_conn_id='postgres_replica')
    ods_hook = PostgresHook(postgres_conn_id='postgres_ods')
    
    ods_hook.run("""
        INSERT INTO ods_orders (
            order_id, customer_id, product_id, order_date, 
            amount, status, load_timestamp
        )
        SELECT 
            id, customer_id, product_id, order_date,
            amount, status, NOW()
        FROM orders_replica
        WHERE order_date >= NOW() - INTERVAL '1 hour'
        ON CONFLICT (order_id) DO UPDATE 
        SET load_timestamp = NOW()
    """)

def transform_to_dds(**kwargs):
    clickhouse_hook = ClickHouseHook(clickhouse_conn_id='clickhouse_dds')
    
    clickhouse_hook.run("""
        INSERT INTO dds.fact_orders
        SELECT
            toDateTime(order_date) as order_datetime,
            order_id,
            customer_id,
            product_id,
            amount,
            status,
            NOW() as processed_dttm
        FROM ods.orders
        WHERE order_date >= now() - INTERVAL 1 HOUR
    """)

def load_to_marts(**kwargs):
    clickhouse_hook = ClickHouseHook(clickhouse_conn_id='clickhouse_marts')
    
    clickhouse_hook.run("""
        INSERT INTO marts.hourly_sales
        SELECT
            toStartOfHour(order_datetime) as hour,
            count() as orders_count,
            sum(amount) as total_amount,
            avg(amount) as avg_order_amount
        FROM dds.fact_orders
        WHERE order_datetime >= now() - INTERVAL 1 HOUR
        GROUP BY hour
    """)

kafka_consumer = PythonOperator(
    task_id='process_kafka_events',
    python_callable=process_kafka_events,
    dag=dag,
)

process_source = PythonOperator(
    task_id='process_source_data',
    python_callable=process_source_data,
    dag=dag,
)

load_ods = PythonOperator(
    task_id='load_to_ods',
    python_callable=load_to_ods,
    dag=dag,
)

transform_dds = PythonOperator(
    task_id='transform_to_dds',
    python_callable=transform_to_dds,
    dag=dag,
)

load_marts = PythonOperator(
    task_id='load_to_marts',
    python_callable=load_to_marts,
    dag=dag,
)

[kafka_consumer, process_source] >> load_ods >> transform_dds >> load_marts
