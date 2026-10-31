#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
check_cluster
ensure_no_gitops
for app in nginx prometheus grafana; do helm uninstall "$app" -n ingress-lab; done
kubectl delete ingress killercoda-nginx killercoda-prometheus killercoda-grafana -n ingress-lab --ignore-not-found
helm uninstall lab-ingress -n ingress-system
# Namespace and unrelated workloads are preserved.
