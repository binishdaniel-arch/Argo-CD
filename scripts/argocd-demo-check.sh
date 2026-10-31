#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
expected="${1:-2}"
[[ "$expected" =~ ^[1-9][0-9]*$ ]] || { echo 'Pass the expected replica count, e.g. 2 or 3' >&2; exit 1; }
kubectl wait application/demo-nginx -n argocd --for=jsonpath='{.status.sync.status}'=Synced --timeout=180s
kubectl wait deployment/demo-nginx -n argocd-demo --for=jsonpath="{.spec.replicas}=$expected" --timeout=180s
kubectl rollout status deployment/demo-nginx -n argocd-demo --timeout=180s
kubectl wait application/demo-nginx -n argocd --for=jsonpath='{.status.health.status}'=Healthy --timeout=180s
ready="$(kubectl get deployment demo-nginx -n argocd-demo -o jsonpath='{.status.readyReplicas}')"
[[ "$ready" == "$expected" ]] || { echo "Expected $expected ready replicas; got $ready" >&2; exit 1; }
echo "PASS demo-nginx: Synced, Healthy, $ready ready replicas"
