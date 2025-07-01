from fastapi import FastAPI
from models import models, database
from routes import incident_routes

app = FastAPI()

@app.get('/')
def root():
    return {'message': 'incident-service running'}

app.include_router(incident_routes.router, prefix="/incidents")

models.Base.metadata.create_all(bind=database.engine)