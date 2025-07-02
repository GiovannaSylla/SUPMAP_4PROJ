from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import requests

app = FastAPI()

# Modèle pour une coordonnée géographique
class Coordinate(BaseModel):
    latitude: float
    longitude: float

# Modèle de la requête d'alerte
class AlertRequest(BaseModel):
    route: List[Coordinate]
    radius_m: float

@app.post("/alerts")
def get_alerts(data: AlertRequest):
    print("Requête reçue:")
    print(data)

    try:
        response = requests.get("http://incident-service:8000/incidents/incidents/")
        if response.status_code != 200:
            print(f"Erreur lors de la récupération des incidents : {response.status_code}")
            print("Réponse brute :", response.text)
            return {"error": "Service d'incidents inaccessible"}, 500
        all_incidents = response.json()
    except Exception as e:
        print("Exception lors de l'appel au service incidents :", e)
        return {"error": "Erreur serveur interne"}, 500

    print("Incidents récupérés :")
    print(all_incidents)

    matching_incidents = []
    for incident in all_incidents:
        for point in data.route:
            distance = ((incident['latitude'] - point.latitude) ** 2 + (incident['longitude'] - point.longitude) ** 2) ** 0.5 * 111_000
            print(f"Distance entre {point} et incident {incident['id']} : {distance:.2f} m")
            if distance <= data.radius_m:
                matching_incidents.append(incident)
                break

    print("Incidents correspondants :")
    print(matching_incidents)

    return matching_incidents