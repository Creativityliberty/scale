# Mon SaaS IA — Starter (FastAPI, Docker, K8s, Scaleway-ready)

Base minimale mais complète pour lancer un SaaS multi-agents IA :
- **Backend**: FastAPI (Python)
- **LLM**: API Génératives Scaleway (via `SCW_API_KEY`)
- **DB**: PostgreSQL
- **Auth**: JWT basique (peut être remplacé par Supabase/Auth0)
- **Dev**: Docker & docker-compose
- **Prod**: Manifests Kubernetes (Kapsule), CI/CD GitHub Actions

## Démarrage rapide (local)

1) Copie le `.env.example` vers `.env` et renseigne les variables :
```bash
cp .env.example .env
```
2) Lance en local :
```bash
docker compose -f deploy/docker-compose.yml up --build
```
3) API disponible sur: http://localhost:8000/docs

## Variables d'environnement clefs
- `SCW_API_KEY` : clé API Scaleway
- `LLM_MODEL` : ex. `llama-3.3-70b-instruct`
- `DATABASE_URL` : ex. `postgresql+psycopg2://app:app@db:5432/app`
- `JWT_SECRET` : secret pour signer les tokens

## Déploiement (aperçu)

- Pousse l'image sur un registry (Scaleway Container Registry)
- Renseigne les Secrets K8s (voir `deploy/k8s/secret-template.yaml`)
- Applique les manifests :
```bash
kubectl apply -f deploy/k8s/
```

## Frontend

Ce starter se concentre sur le backend/infra. Tu peux brancher un frontend React/Vite sur l'API (`/api/*`).

— Bon build !


## Frontend (React/Vite)

- Dossier: `frontend/`
- Dev local: `cd frontend && npm i && npm run dev` (proxy `/api` → http://localhost:8000)
- Docker local: `docker compose -f deploy/docker-compose.yml up --build` (frontend exposé sur `http://localhost:3000`)

## CI: Build images

- API: `.github/workflows/docker-build.yml` (pousse `mon-saas-ia-api:latest`)
- FRONT: crée un job similaire si besoin, ou adapte le même workflow pour builder `frontend` :
  ```yaml
  - name: Build and push (frontend)
    uses: docker/build-push-action@v6
    with:
      context: ./frontend
      push: true
      tags: rg.${{ vars.SCW_REGION }}.scw.cloud/${{ vars.SCW_NAMESPACE }}/mon-saas-ia-frontend:latest
  ```

## CD: Déploiement Kubernetes

- Workflow: `.github/workflows/deploy-k8s.yml`
- Secrets requis :
  - `KUBECONFIG_CONTENT` : contenu kubeconfig (base64 ou brut)
  - Secrets d'appli (voir `deploy/k8s/secret-template.yaml`) — recommande de les créer via :
    ```bash
    kubectl -n mon-saas-ia create secret generic mon-saas-ia-secrets       --from-literal=SCW_API_KEY="scw-xxxxx"       --from-literal=LLM_MODEL="llama-3.3-70b-instruct"       --from-literal=JWT_SECRET="change_me"       --from-literal=DATABASE_URL="postgresql+psycopg2://app:app@db:5432/app"
    ```

## DNS & TLS

- Remplace `app.example.com` et `api.example.com` par ton domaine.
- Ajoute un Ingress Controller (NGINX) + cert-manager (Let's Encrypt) pour TLS auto.


## Certificats TLS (cert-manager + Let's Encrypt)

### Installation rapide de cert-manager (cluster)
Choisis UNE méthode :
- **Helm** (recommandé) :
  ```bash
  helm repo add jetstack https://charts.jetstack.io
  helm repo update
  helm install cert-manager jetstack/cert-manager     --namespace cert-manager --create-namespace     --set crds.install=true
  ```
- **Kubectl** (manifeste YAML complet) :
  ```bash
  kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
  ```

### ClusterIssuer
Renseigne `.env.deploy` puis génère les manifests :
```bash
cp .env.deploy.example .env.deploy
# édite APP_DOMAIN, API_DOMAIN, ACME_EMAIL, etc.
bash deploy/render.sh
```

Cert-manager créera/renouvellera les certificats via HTTP-01 sur NGINX Ingress.
# scale
