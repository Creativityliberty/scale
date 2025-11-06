apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${CLUSTER_ISSUER}
spec:
  acme:
    # ACME server pour Let's Encrypt prod (pour tests, tu peux utiliser staging: https://acme-staging-v02.api.letsencrypt.org/directory)
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${ACME_EMAIL}
    privateKeySecretRef:
      name: ${CLUSTER_ISSUER}-key
    solvers:
    - http01:
        ingress:
          class: nginx
