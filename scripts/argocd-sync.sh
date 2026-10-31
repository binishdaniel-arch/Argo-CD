#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
check_cluster
selection="${1:-all}"
case "$selection" in
  all) apps=(nginx prometheus grafana) ;;
  nginx|prometheus|grafana) apps=("$selection") ;;
  *) echo 'Usage: bash scripts/argocd-sync.sh [all|nginx|prometheus|grafana]' >&2; exit 1 ;;
esac
for name in "${apps[@]}"; do
  app="lab-$name"
  request="lab-bash-$(date +%s)-$$-$RANDOM"
  patch="{\"operation\":{\"initiatedBy\":{\"username\":\"$request\"},\"sync\":{\"prune\":false,\"syncStrategy\":{\"hook\":{}}}}}"
  kubectl patch application "$app" -n argocd --type merge -p "$patch"
  deadline=$((SECONDS + 300))
  complete=false
  while (( SECONDS < deadline )); do
    who="$(kubectl get application "$app" -n argocd -o jsonpath='{.status.operationState.operation.initiatedBy.username}')"
    phase="$(kubectl get application "$app" -n argocd -o jsonpath='{.status.operationState.phase}')"
    if [[ "$who" == "$request" ]]; then
      case "$phase" in
        Succeeded) complete=true; break ;;
        Failed|Error) kubectl get application "$app" -n argocd -o yaml; exit 1 ;;
      esac
    fi
    sleep 2
  done
  [[ "$complete" == true ]] || { echo "Sync timed out: $app" >&2; exit 1; }
  kubectl wait "application/$app" -n argocd --for=jsonpath='{.status.sync.status}'=Synced --timeout=120s
  kubectl rollout status "deployment/$name" -n ingress-lab --timeout=180s
  kubectl wait "application/$app" -n argocd --for=jsonpath='{.status.health.status}'=Healthy --timeout=180s
done
