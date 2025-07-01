# app/routes/incident_routes.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from models.models import Incident  # Ton modèle SQLAlchemy
from models.schemas import IncidentBase, IncidentDisplay  # Ton schéma Pydantic
from models.database import get_db  # Fonction pour obtenir la session DB

router = APIRouter()

@router.post("/incidents/")
def create_incident(incident: IncidentBase, db: Session = Depends(get_db)):
    new_incident = Incident(**incident.dict())
    db.add(new_incident)
    db.commit()
    db.refresh(new_incident)
    return new_incident

@router.get("/incidents/", response_model=list[IncidentDisplay])
def get_all_incidents(db: Session = Depends(get_db)):
    return db.query(Incident).all()