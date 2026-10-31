#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
check_cluster
kubectl get namespace ingress-lab >/dev/null
helm lint ./vendor/traefik-42.2.0.tgz -f controller-values.yaml
for app in nginx prometheus grafana; do
  helm lint "./charts/$app" --strict
  helm template "$app" "./charts/$app" -n ingress-lab | kubectl apply --dry-run=server -n ingress-lab -f -
done
if [[ -n "$(kubectl get crd applications.argoproj.io --ignore-not-found -o name)" ]]; then
  helm lint ./vendor/argo-cd-10.11.6.tgz -f gitops/argocd-values.yaml
  kubectl apply --dry-run=server -f gitops/bootstrap/project.yaml
  kubectl apply --dry-run=server -f gitops/applications/
  kubectl apply --dry-run=server -f gitops/argocd-ingress.yaml
fi
