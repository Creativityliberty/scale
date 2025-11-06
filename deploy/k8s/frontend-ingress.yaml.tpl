apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: ${K8S_NAMESPACE}
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: ${CLUSTER_ISSUER}
spec:
  rules:
    - host: ${APP_DOMAIN}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web
                port:
                  number: 80
  tls:
    - hosts:
        - ${APP_DOMAIN}
      secretName: web-tls
