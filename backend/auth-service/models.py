from sqlalchemy import Column, Integer, String
from database import Base


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    auth0_id = Column(String, unique=True, index=True)  # sub from Auth0
    email = Column(String, unique=True)
    role = Column(String, default="contributeur")
