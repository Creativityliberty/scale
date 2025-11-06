import os
from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from jose import jwt
from passlib.context import CryptContext

router = APIRouter()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

JWT_SECRET = os.getenv("JWT_SECRET", "change_me")
JWT_EXPIRE_MIN = int(os.getenv("JWT_EXPIRE_MIN", "60"))

# Dummy user store (à remplacer par DB ou Supabase)
FAKE_USER = {"email": "demo@example.com", "password_hash": pwd_context.hash("demo123")}

class LoginIn(BaseModel):
    email: str
    password: str

@router.post("/login")
def login(data: LoginIn):
    if data.email != FAKE_USER["email"] or not pwd_context.verify(data.password, FAKE_USER["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    exp = datetime.utcnow() + timedelta(minutes=JWT_EXPIRE_MIN)
    token = jwt.encode({"sub": data.email, "exp": exp}, JWT_SECRET, algorithm="HS256")
    return {"access_token": token, "token_type": "bearer", "expires_in": JWT_EXPIRE_MIN * 60}
