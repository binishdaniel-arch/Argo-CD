#!/usr/bin/env bash
# Lab 2, step 1: install ONLY the Argo CD control plane; no Applications are created.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
check_cluster
url=http://localhost:8090
if [[ "$LAB_ENV" == killercoda ]]; then
  url="$(sed 's/PORT/8090/g' /etc/killercoda/host | tr -d '\r\n')"
fi
helm upgrade --install argocd ./vendor/argo-cd-10.11.6.tgz -n argocd --create-namespace -f gitops/argocd-values.yaml --set-string "configs.cm.url=$url" --wait --timeout 10m
kubectl get pods -n argocd
echo "Argo CD installed. Next: forward service/argocd-server on port 8090 and open $url"
echo 'No demo Application was created. Continue with Lab 2 step 2.'
