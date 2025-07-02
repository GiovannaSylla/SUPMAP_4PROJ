from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
import datetime

Base = declarative_base()

class Trajet(Base):
    __tablename__ = 'trajets'
    id = Column(Integer, primary_key=True)
    user_id = Column(String, nullable=False)
    origine = Column(String, nullable=False)
    destination = Column(String, nullable=False)
    duree = Column(Float)  # en minutes
    distance = Column(Float)  # en km
    date = Column(DateTime, default=datetime.datetime.utcnow)

class Signalement(Base):
    __tablename__ = 'signalements'
    id = Column(Integer, primary_key=True)
    user_id = Column(String, nullable=False)
    type = Column(String, nullable=False)  # exemple : accident, bouchon, etc.
    latitude = Column(Float)
    longitude = Column(Float)
    date = Column(DateTime, default=datetime.datetime.utcnow)