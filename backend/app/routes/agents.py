import os, requests
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()

SCW_API_KEY = os.getenv("SCW_API_KEY", "")
SCW_GEN_BASE = os.getenv("SCW_GEN_BASE", "https://api.scaleway.ai/generative/v1beta1")
LLM_MODEL    = os.getenv("LLM_MODEL", "llama-3.3-70b-instruct")

class AskIn(BaseModel):
    agent: str = "writer"
    prompt: str

def call_llm(prompt: str) -> str:
    if not SCW_API_KEY:
        raise HTTPException(status_code=500, detail="SCW_API_KEY not configured")
    url = f"{SCW_GEN_BASE}/text:generate"
    headers = {"Authorization": f"Bearer {SCW_API_KEY}", "Content-Type": "application/json"}
    payload = {
        "model": LLM_MODEL,
        "prompt": prompt,
        "max_tokens": 512
    }
    r = requests.post(url, json=payload, headers=headers, timeout=60)
    if r.status_code != 200:
        raise HTTPException(status_code=502, detail=f"LLM error: {r.text}")
    data = r.json()
    # La forme peut varier selon l'API; on garde simple ici
    return data.get("text") or data

@router.post("/ask")
def ask(data: AskIn):
    # Dispatcher simplifié par "agent"
    if data.agent == "writer":
        p = f"Tu es un agent rédacteur. Réponds clairement.

{data.prompt}"
    elif data.agent == "analyst":
        p = f"Tu es un agent analyste. Donne une analyse synthétique.

{data.prompt}"
    elif data.agent == "moderator":
        p = f"Tu es un agent modérateur. Vérifie la sécurité du contenu.

{data.prompt}"
    else:
        p = data.prompt
    out = call_llm(p)
    return {"agent": data.agent, "response": out}
