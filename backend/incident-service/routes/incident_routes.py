from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from . import models, database

router = APIRouter()

# Dépendance pour obtenir une session de BDD
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Route pour ajouter un nouvel incident
@router.post("/incidents")
def create_incident(incident: models.Incident, db: Session = Depends(get_db)):
    db.add(incident)
    db.commit()
    db.refresh(incident)
    return incident

# Route pour lister tous les incidents
@router.get("/incidents")
def get_incidents(db: Session = Depends(get_db)):
    return db.query(models.Incident).all()