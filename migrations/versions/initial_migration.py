"""initial migration

Revision ID: initial
Revises: 
Create Date: 2023-12-23 22:13:14.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic
revision = 'initial'
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    # Создание схемы ods
    op.execute('CREATE SCHEMA IF NOT EXISTS ods')
    
    # Создание таблицы orders
    op.create_table('orders',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('source_address_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('target_address_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('extra', sa.Text(), nullable=True),
        sa.Column('registered_at', postgresql.TIMESTAMP(timezone=True), nullable=False),
        sa.Column('load_timestamp', postgresql.TIMESTAMP(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.Column('is_valid', sa.Boolean(), default=True),
        sa.PrimaryKeyConstraint('id'),
        schema='ods'
    )
    
    # Создание таблицы deliveries
    op.create_table('deliveries',
        sa.Column('pipeline_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('cost', sa.Numeric(precision=10, scale=2), nullable=True),
        sa.Column('estimated_at', postgresql.TIMESTAMP(timezone=True), nullable=True),
        sa.Column('performer_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('assigned_at', postgresql.TIMESTAMP(timezone=True), nullable=True),
        sa.Column('released_at', postgresql.TIMESTAMP(timezone=True), nullable=True),
        sa.Column('load_timestamp', postgresql.TIMESTAMP(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.Column('is_valid', sa.Boolean(), default=True),
        sa.PrimaryKeyConstraint('pipeline_id'),
        schema='ods'
    )
    
    # Создание таблицы performers
    op.create_table('performers',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('load_timestamp', postgresql.TIMESTAMP(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.Column('is_valid', sa.Boolean(), default=True),
        sa.PrimaryKeyConstraint('id'),
        schema='ods'
    )
    
    # Создание таблицы events
    op.create_table('events',
        sa.Column('event_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('event_type', sa.String(length=50), nullable=False),
        sa.Column('event_data', postgresql.JSONB(), nullable=False),
        sa.Column('event_timestamp', postgresql.TIMESTAMP(timezone=True), nullable=False),
        sa.Column('load_timestamp', postgresql.TIMESTAMP(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.Column('is_valid', sa.Boolean(), default=True),
        sa.PrimaryKeyConstraint('event_id'),
        schema='ods'
    )
    
    # Создание индексов
    op.create_index('idx_orders_registered', 'orders', ['registered_at'], schema='ods')
    op.create_index('idx_orders_addresses', 'orders', ['source_address_id', 'target_address_id'], schema='ods')
    
    op.create_index('idx_deliveries_performer', 'deliveries', ['performer_id'], schema='ods')
    op.create_index('idx_deliveries_pipeline', 'deliveries', ['pipeline_id'], schema='ods')
    op.create_index('idx_deliveries_timestamps', 'deliveries', ['estimated_at', 'assigned_at', 'released_at'], schema='ods')
    
    op.create_index('idx_events_type', 'events', ['event_type'], schema='ods')
    op.create_index('idx_events_timestamp', 'events', ['event_timestamp'], schema='ods')
    op.create_index('idx_events_data', 'events', ['event_data'], schema='ods', postgresql_using='gin')

def downgrade():
    # Удаление индексов
    op.drop_index('idx_events_data', table_name='events', schema='ods')
    op.drop_index('idx_events_timestamp', table_name='events', schema='ods')
    op.drop_index('idx_events_type', table_name='events', schema='ods')
    
    op.drop_index('idx_deliveries_timestamps', table_name='deliveries', schema='ods')
    op.drop_index('idx_deliveries_pipeline', table_name='deliveries', schema='ods')
    op.drop_index('idx_deliveries_performer', table_name='deliveries', schema='ods')
    
    op.drop_index('idx_orders_addresses', table_name='orders', schema='ods')
    op.drop_index('idx_orders_registered', table_name='orders', schema='ods')
    
    # Удаление таблиц
    op.drop_table('events', schema='ods')
    op.drop_table('performers', schema='ods')
    op.drop_table('deliveries', schema='ods')
    op.drop_table('orders', schema='ods')
    
    # Удаление схемы
    op.execute('DROP SCHEMA IF EXISTS ods')
