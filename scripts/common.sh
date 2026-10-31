#!/usr/bin/env bash
# Shared by Git Bash on Windows and Bash in KillerCoda. Source, do not execute.
set -euo pipefail
export MSYS_NO_PATHCONV=1
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) LAB_CURL_SINK=NUL ;;
  *) LAB_CURL_SINK=/dev/null ;;
esac
LAB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$LAB_ROOT"
if [[ -z "${LAB_ENV:-}" ]]; then
  if [[ -f /etc/killercoda/host ]]; then LAB_ENV=killercoda; else LAB_ENV=desktop; fi
fi
require_tools() {
  local tool
  for tool in "$@"; do command -v "$tool" >/dev/null || { echo "Missing command: $tool" >&2; return 1; }; done
}
check_cluster() {
  require_tools kubectl helm
  local context
  context="$(kubectl config current-context)"
  case "$LAB_ENV" in
    desktop) [[ "$context" == docker-desktop ]] || { echo "Expected docker-desktop; found $context. Use kubectl config use-context docker-desktop." >&2; return 1; } ;;
    killercoda) [[ -f /etc/killercoda/host ]] || { echo 'KillerCoda marker missing: run inside the KillerCoda Kubernetes terminal.' >&2; return 1; } ;;
    *) echo "Unknown LAB_ENV: $LAB_ENV" >&2; return 1 ;;
  esac
  kubectl get nodes
  kubectl wait --for=condition=Ready nodes --all --timeout=120s
}
ensure_no_gitops() {
  local crd apps
  crd="$(kubectl get crd applications.argoproj.io --ignore-not-found -o name)"
  if [[ -n "$crd" ]]; then
    apps="$(kubectl get applications.argoproj.io -n argocd --ignore-not-found -o name)"
    if printf '%s\n' "$apps" | grep -Eq 'application.argoproj.io/lab-(nginx|prometheus|grafana)$'; then
      echo 'Argo CD owns the lab apps. Follow Lab 2 hand-back before Helm deployment/cleanup.' >&2
      return 1
    fi
  fi
}
