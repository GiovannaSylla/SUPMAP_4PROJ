from fastapi import FastAPI
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models.models import Base
import os
from routes.routes import router
app.include_router(router)

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@postgres:5432/supmap")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Création des tables
Base.metadata.create_all(bind=engine)

app = FastAPI()