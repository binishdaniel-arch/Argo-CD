#!/usr/bin/env bash
set -euo pipefail
app="${1:-}"; host="${2:-}"
[[ "$host" =~ ^[A-Za-z0-9][A-Za-z0-9.-]*[A-Za-z0-9]$ ]] || { echo 'Pass a valid generated DNS hostname' >&2; exit 1; }
case "$app" in
  nginx) service=nginx; target=80; ns=ingress-lab ;;
  prometheus) service=prometheus; target=9090; ns=ingress-lab ;;
  grafana) service=grafana; target=3000; ns=ingress-lab ;;
  argocd) service=argocd-server; target=80; ns=argocd ;;
  *) echo 'App must be nginx, prometheus, grafana or argocd' >&2; exit 1 ;;
esac
cat <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: killercoda-$app
  namespace: $ns
spec:
  ingressClassName: traefik
  rules:
    - host: $host
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: $service
                port:
                  number: $target
EOF
