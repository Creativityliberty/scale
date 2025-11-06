#!/usr/bin/env bash
set -euo pipefail

if [ ! -f ".env.deploy" ]; then
  echo "❌ Fichier .env.deploy introuvable. Copie .env.deploy.example -> .env.deploy et renseigne les variables."
  exit 1
fi

# Charge les variables
set -a
source .env.deploy
set +a

OUT="deploy/rendered"
mkdir -p "$OUT"

echo "➡️  Rendu des templates avec envsubst → $OUT"

envsubst < deploy/cert-manager/cluster-issuer.yaml.tpl > "$OUT/cluster-issuer.yaml"
envsubst < deploy/k8s/ingress.yaml.tpl > "$OUT/ingress.yaml"
envsubst < deploy/k8s/frontend-ingress.yaml.tpl > "$OUT/frontend-ingress.yaml"

echo "✅ Fichiers générés:"
ls -1 "$OUT"

echo
echo "ℹ️  Applique maintenant dans cet ordre (ingress controller déjà présent, ex. nginx-ingress) :"
echo "kubectl apply -f deploy/k8s/namespace.yaml"
echo "kubectl apply -f $OUT/cluster-issuer.yaml"
echo "kubectl -n ${K8S_NAMESPACE} apply -f deploy/k8s/secret-template.yaml    # ⚠️ Remplacer par création de Secret depuis GitHub Actions si possible"
echo "kubectl -n ${K8S_NAMESPACE} apply -f deploy/k8s/deployment.yaml"
echo "kubectl -n ${K8S_NAMESPACE} apply -f deploy/k8s/service.yaml"
echo "kubectl -n ${K8S_NAMESPACE} apply -f $OUT/ingress.yaml"
echo "kubectl -n ${K8S_NAMESPACE} apply -f deploy/k8s/frontend-deployment.yaml"
echo "kubectl -n ${K8S_NAMESPACE} apply -f deploy/k8s/frontend-service.yaml"
echo "kubectl -n ${K8S_NAMESPACE} apply -f $OUT/frontend-ingress.yaml"
echo
echo "🔎 Vérifie les certificats :"
echo "kubectl get certificate -A"
echo "kubectl describe challenge -A | sed -n '1,120p'"
