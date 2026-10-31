#!/usr/bin/env bash
# Foreground launcher: Ctrl+C stops its own four port-forward processes.
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
[[ -f /etc/killercoda/host ]] || { echo 'Run this only inside a KillerCoda environment.' >&2; exit 1; }
require_tools kubectl sed
kubectl get svc lab-ingress-traefik -n ingress-system >/dev/null
pids=()
seen_hosts=()
stop_forwards() {
  local pid
  for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done
  for pid in "${pids[@]}"; do wait "$pid" 2>/dev/null || true; done
}
trap stop_forwards EXIT
trap 'exit 130' INT TERM
mkdir -p .lab-runtime
for app in nginx prometheus grafana argocd; do
  case "$app" in
    nginx) port=8080; service=nginx; target=80; ns=ingress-lab ;;
    prometheus) port=8081; service=prometheus; target=9090; ns=ingress-lab ;;
    grafana) port=8082; service=grafana; target=3000; ns=ingress-lab ;;
    argocd) port=8083; service=argocd-server; target=80; ns=argocd ;;
  esac
  if ! kubectl get svc "$service" -n "$ns" >/dev/null 2>&1; then
    echo "Skipping $app (not installed yet). Rerun after Argo setup."; continue
  fi
  url="$(sed "s/PORT/$port/g" /etc/killercoda/host | tr -d '\r\n')"
  host="${url#*://}"; host="${host%%/*}"; host="${host%%:*}"
  [[ "$host" =~ ^[A-Za-z0-9.-]+$ ]] || { echo "Unexpected KillerCoda hostname: $host" >&2; exit 1; }
  for previous in "${seen_hosts[@]}"; do
    [[ "$previous" != "$host" ]] || { echo 'Generated URLs share a hostname; unique hosts are required for this ingress exercise.' >&2; exit 1; }
  done
  seen_hosts+=("$host")
  bash scripts/render-killercoda-ingress.sh "$app" "$host" | kubectl apply -f -
  if [[ "$app" == argocd ]]; then
    kubectl patch configmap argocd-cm -n argocd --type merge -p "{\"data\":{\"url\":\"$url\"}}"
  fi
  kubectl port-forward -n ingress-system svc/lab-ingress-traefik "$port:80" --address 0.0.0.0 >".lab-runtime/$app-forward.log" 2>&1 &
  pids+=("$!")
  printf '%s: %s\n' "$app" "$url"
done
echo 'Open the printed browser URLs (or Traffic / Ports). Every route goes through Traefik.'
echo 'Keep this terminal running. Ctrl+C stops these forwards. Rerun after a Traefik rollout.'
# A failed forward ends the launcher rather than silently leaving a missing app URL.
wait -n "${pids[@]}"
echo 'A port-forward ended. Inspect .lab-runtime/*-forward.log and rerun.' >&2
exit 1
