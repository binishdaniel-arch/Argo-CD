#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
require_tools kubectl
address=127.0.0.1
url=http://localhost:8090
if [[ -f /etc/killercoda/host ]]; then
  address=0.0.0.0
  url="$(sed 's/PORT/8090/g' /etc/killercoda/host | tr -d '\r\n')"
fi
echo "Open Argo CD: $url"
echo 'Keep this terminal running. Use a second terminal for the remaining commands.'
exec kubectl port-forward -n argocd svc/argocd-server 8090:80 --address "$address"
