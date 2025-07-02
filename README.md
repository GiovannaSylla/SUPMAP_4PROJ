📱 SUPMAP – Application mobile de navigation en temps réel

SUPMAP est une application mobile Flutter de navigation collaborative. Elle permet aux utilisateurs :
	•	de signaler des incidents en temps réel (accidents, bouchons, routes bloquées),
	•	d’obtenir un itinéraire optimisé jusqu’à une destination,
	•	de suivre la navigation GPS simulée,
	•	et, dans la version avancée, d’enregistrer ces trajets/incidents dans une base PostgreSQL via une API FastAPI.

⸻

🚀 Lancer le projet Flutter

📋 Prérequis
	•	✅ Avoir Flutter installé localement (Flutter 3.x recommandé)
	•	✅ Avoir un émulateur Android/iOS ou un smartphone connecté via USB
	•	✅ Avoir un compte Google Maps API (clé requise)
	•	✅ Un backend local tournant avec FastAPI (optionnel si non utilisé)

⸻

⚙️ Étapes de lancement : Cloner le projet

	1.	git clone https://github.com/SUPMAP_4PROJ.git
                cd supmap

-Installer les dépendances

	2.	flutter pub get

-Nettoyer le cache (si besoin)

	3.	flutter clean
                flutter pub get

-Configurer votre clé Google Maps: Dans un fichier .env (ou dans lib/.env selon l’implémentation), ajoutez :


	4.	GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_API_KEY

-Lancer l’application


	5. flutter run	



⸻

🔧 Technologies utilisées

✅ Côté mobile (Flutter)
	•	google_maps_flutter – affichage de la carte
	•	location – position GPS en temps réel
	•	flutter_polyline_points – tracé des itinéraires
	•	geolocator – localisation fine
	•	flutter_dotenv – gestion des variables d’environnement
	•	http – communication avec l’API FastAPI
	•	flutter_secure_storage (si authentification sécurisée)

✅ Côté backend ( FastAPI)
	•	Langage : Python 3.11
	•	Services micro :
	•	Authentification (JWT)
	•	Gestion des incidents
	•	Navigation
	•	Analyse/statistiques
	•	FastAPI – framework Python pour les microservices
	•	PostgreSQL – base de données pour stocker incidents & trajets
	•	Swagger – documentation des endpoints API
	•	Uvicorn – serveur d’application

⸻

🧪 Fonctionnalités principales
	•	Authentification via Auth0
	•	Affichage de la carte avec position actuelle
	•	Saisie d’une destination via Autocomplete (Google Place API)
	•	Visualisation de plusieurs itinéraires optimisés
  • Bouton “Y aller” pour lancer la navigation simulée
	•	Navigation simulée avec suivi de position
	•	Signalement d’incidents ( accident, embouteillage, route bloquée, policier etc..)
	•	Affichage des incidents en temps réel
	•	Enregistrement des trajets dans la base de données (via API FastAPI)

⸻

🛠️ Backend API – (en local avec FastAPI)

Prérequis
	•	Python 3.11
	•	PostgreSQL installé localement ou via Docker

Lancer le backend

docker compose up --build

uvicorn main:app --reload --host 0.0.0.0 --port 8000

Accéder à Swagger : http://localhost:8000/docs

⸻

📈 À venir (Backlog / Prochaines étapes)
	•	Enrichir les alertes en fonction de la distance
	•	Prédictions des embouteillages (Machine Learning)
	•	Dashboard statistiques des incidents (dans le backend)
 
⸻

📌 Remarques
	•	Aucun site web n’est prévu dans le projet
	•	L’application peut être testée sur Android et iOS
	•	Le projet respecte une architecture propre avec services bien séparés :
	•	auth_service
	•	incident_service
	•	navigation_service
	•	data_service (statistiques, analyse, prédiction à venir)

⸻

👥 Équipe projet
	•	Aminata Giovanna Sylla 
	•	Rudy Bullier
  •	Oussamah

⸻
