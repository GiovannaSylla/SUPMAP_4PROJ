from fastapi import Request, HTTPException
from jose import jwt
import requests
import os

from dotenv import load_dotenv
load_dotenv()

AUTH0_DOMAIN = os.getenv("AUTH0_DOMAIN")
API_AUDIENCE = os.getenv("AUTH0_API_AUDIENCE")
ALGORITHMS = ["RS256"]

def get_jwks():
    url = f"https://{AUTH0_DOMAIN}/.well-known/jwks.json"
    return requests.get(url).json()

def verify_jwt_token(token: str):
    jwks = get_jwks()
    unverified_header = jwt.get_unverified_header(token)
    rsa_key = {}
    for key in jwks["keys"]:
        if key["kid"] == unverified_header["kid"]:
            rsa_key = {
                "kty": key["kty"],
                "kid": key["kid"],
                "use": key["use"],
                "n": key["n"],
                "e": key["e"]
            }
    if rsa_key:
        try:
            payload = jwt.decode(token, rsa_key, algorithms=ALGORITHMS, audience=API_AUDIENCE, issuer=f"https://{AUTH0_DOMAIN}/")
            return payload
        except Exception:
            raise HTTPException(status_code=401, detail="Token invalide ou expiré")
    raise HTTPException(status_code=401, detail="Clé RSA introuvable")
