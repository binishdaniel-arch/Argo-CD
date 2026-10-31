#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
check_cluster
kubectl get namespace ingress-lab
kubectl get ingressclass traefik
helm upgrade --install lab-ingress ./vendor/traefik-42.2.0.tgz -n ingress-system -f controller-values.yaml --wait --timeout 5m
helm upgrade --install argocd ./vendor/argo-cd-10.11.6.tgz -n argocd --create-namespace -f gitops/argocd-values.yaml --wait --timeout 10m
kubectl apply -f gitops/argocd-ingress.yaml
kubectl apply -f gitops/bootstrap/project.yaml
kubectl apply -f gitops/applications/
echo 'Manual-sync Applications created. Inspect the diff in Lab 2 before syncing.'
