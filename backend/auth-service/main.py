from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from auth0 import verify_jwt_token

app = FastAPI()

# CORS : pour autoriser ton front Flutter à appeler l’API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  #
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/me")
async def get_current_user(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Token manquant ou mal formé")

    token = auth_header.split(" ")[1]

    try:
        payload = verify_jwt_token(token)
        # Exemple de payload : {'sub': 'auth0|abc', 'email': 'ex@mail.com', 'role': 'admin'}
        return {
            "user_id": payload.get("sub"),
            "email": payload.get("email"),
            "role": payload.get("role")  # ← récupère le rôle
        }
    except HTTPException as e:
        raise e