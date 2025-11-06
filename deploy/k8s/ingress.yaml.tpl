apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api
  namespace: ${K8S_NAMESPACE}
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: ${CLUSTER_ISSUER}
spec:
  rules:
    - host: ${API_DOMAIN}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: api
                port:
                  number: 80
  tls:
    - hosts:
        - ${API_DOMAIN}
      secretName: api-tls
