#!/bin/bash
set -e

echo "🚀 Configuration Scaleway CLI..."

: "${SCW_ACCESS_KEY:?Variable SCW_ACCESS_KEY non définie}"
: "${SCW_SECRET_KEY:?Variable SCW_SECRET_KEY non définie}"
: "${SCW_REGION:=fr-par}"
: "${SCW_NAMESPACE:=mon-saas-ia}"

if ! command -v scw &> /dev/null; then
    echo "📦 Installation Scaleway CLI..."
    curl -s https://raw.githubusercontent.com/scaleway/scaleway-cli/master/scripts/get.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "🔑 Init Scaleway CLI..."
scw init access-key="$SCW_ACCESS_KEY" \
    secret-key="$SCW_SECRET_KEY" \
    default-region="$SCW_REGION" \
    default-zone="${SCW_REGION}-1" \
    send-telemetry=false \
    with-ssh-key=false

echo "🐳 Login Container Registry..."
scw registry login

echo "📦 Namespace registry..."
scw registry namespace create name="$SCW_NAMESPACE" || echo "Existe déjà"

if [ -n "$CLUSTER_ID" ]; then
    echo "☸️ Kubeconfig cluster $CLUSTER_ID..."
    scw k8s kubeconfig install "$CLUSTER_ID" -o
fi

echo "✅ Configuration terminée !"