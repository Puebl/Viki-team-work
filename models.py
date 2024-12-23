from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey, Text, Boolean, Numeric, JSON
from sqlalchemy.dialects.postgresql import UUID, JSONB, TIMESTAMP
from sqlalchemy.ext.declarative import declarative_base
import uuid

Base = declarative_base()

class Orders(Base):
    __tablename__ = 'orders'
    __table_args__ = {'schema': 'ods'}
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    source_address_id = Column(UUID(as_uuid=True), nullable=False)
    target_address_id = Column(UUID(as_uuid=True), nullable=False)
    extra = Column(Text)
    registered_at = Column(TIMESTAMP(timezone=True), nullable=False)
    load_timestamp = Column(TIMESTAMP(timezone=True), server_default='CURRENT_TIMESTAMP')
    is_valid = Column(Boolean, default=True)

class Deliveries(Base):
    __tablename__ = 'deliveries'
    __table_args__ = {'schema': 'ods'}
    
    pipeline_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cost = Column(Numeric(10, 2))
    estimated_at = Column(TIMESTAMP(timezone=True))
    performer_id = Column(UUID(as_uuid=True))
    assigned_at = Column(TIMESTAMP(timezone=True))
    released_at = Column(TIMESTAMP(timezone=True))
    load_timestamp = Column(TIMESTAMP(timezone=True), server_default='CURRENT_TIMESTAMP')
    is_valid = Column(Boolean, default=True)

class Performers(Base):
    __tablename__ = 'performers'
    __table_args__ = {'schema': 'ods'}
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    load_timestamp = Column(TIMESTAMP(timezone=True), server_default='CURRENT_TIMESTAMP')
    is_valid = Column(Boolean, default=True)

class Events(Base):
    __tablename__ = 'events'
    __table_args__ = {'schema': 'ods'}
    
    event_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_type = Column(String(50), nullable=False)
    event_data = Column(JSONB, nullable=False)
    event_timestamp = Column(TIMESTAMP(timezone=True), nullable=False)
    load_timestamp = Column(TIMESTAMP(timezone=True), server_default='CURRENT_TIMESTAMP')
    is_valid = Column(Boolean, default=True)
