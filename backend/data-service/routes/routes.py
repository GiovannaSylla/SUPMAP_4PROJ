from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from models.models import Trajet
from main import SessionLocal

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/trajets/")
def create_trajet(user_id: str, origine: str, destination: str, duree: float, distance: float, db: Session = Depends(get_db)):
    trajet = Trajet(user_id=user_id, origine=origine, destination=destination, duree=duree, distance=distance)
    db.add(trajet)
    db.commit()
    db.refresh(trajet)
    return {"message": "Trajet enregistré", "trajet_id": trajet.id}