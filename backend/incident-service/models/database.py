from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os
import time

# Variables d'environnement avec valeurs par défaut
POSTGRES_USER = os.getenv("POSTGRES_USER", "supuser")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "suppassword")
POSTGRES_DB = os.getenv("POSTGRES_DB", "supmap")
POSTGRES_HOST = os.getenv("POSTGRES_HOST", "db")
POSTGRES_PORT = os.getenv("POSTGRES_PORT", "5432")

DATABASE_URL = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"

# Retente plusieurs fois si la base n’est pas encore prête
max_tries = 10
for i in range(max_tries):
    try:
        engine = create_engine(DATABASE_URL)
        conn = engine.connect()
        conn.close()
        break
    except Exception as e:
        print(f"Tentative {i+1}/{max_tries} : Base de données non prête, nouvelle tentative dans 3s...")
        time.sleep(3)
else:
    raise Exception("Impossible de se connecter à la base de données après plusieurs tentatives.")

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

from fastapi import Depends

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()