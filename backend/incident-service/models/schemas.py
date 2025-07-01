from pydantic import BaseModel
from datetime import datetime

class IncidentBase(BaseModel):
    title: str
    description: str
    latitude: float
    longitude: float
    timestamp: datetime
class IncidentDisplay(IncidentBase):
    id: int

    class Config:
        from_attributes = True