#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
require_tools kubectl
for name in nginx prometheus grafana; do
  state="$(kubectl get application "lab-$name" -n argocd -o jsonpath='{.status.sync.status}/{.status.health.status}')"
  [[ "$state" == Synced/Healthy ]] || { echo "lab-$name: $state" >&2; exit 1; }
  ready="$(kubectl get deployment "$name" -n ingress-lab -o jsonpath='{.status.readyReplicas}')"
  [[ "$ready" == 2 ]] || { echo "$name needs 2 ready replicas; found $ready" >&2; exit 1; }
  revision="$(kubectl get application "lab-$name" -n argocd -o jsonpath='{.status.sync.revision}')"
  echo "PASS lab-$name: Synced/Healthy, 2 ready replicas, Git $revision"
done
