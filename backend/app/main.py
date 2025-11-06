import os
from fastapi import FastAPI
from .routes import auth, agents, health

APP_NAME = os.getenv("APP_NAME", "mon-saas-ia")

app = FastAPI(title=APP_NAME)

app.include_router(health.router, prefix="", tags=["health"])
app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(agents.router, prefix="/api/agents", tags=["agents"])
