#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
check_cluster
ensure_no_gitops
helm upgrade --install lab-ingress ./vendor/traefik-42.2.0.tgz -n ingress-system --create-namespace -f controller-values.yaml --wait --timeout 5m
for app in nginx prometheus grafana; do
  helm upgrade --install "$app" "./charts/$app" -n ingress-lab --create-namespace --wait --timeout 5m
done
kubectl get deployment,pods,svc,ingress -n ingress-lab
