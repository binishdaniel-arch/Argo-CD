#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
case "${1:-manual}" in
  auto) value=true ;;
  manual) value=false ;;
  *) echo 'Usage: bash scripts/argocd-policy.sh [auto|manual]' >&2; exit 1 ;;
esac
sed -i -E "s/enabled: (true|false)/enabled: $value/; s/selfHeal: (true|false)/selfHeal: $value/" gitops/applications/nginx.yaml
echo 'Working file updated. Review git diff, commit/push, then kubectl apply the Application file.'
