#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
require_tools kubectl curl
base="${LAB_BASE_URL:-http://127.0.0.1:8080}"
for app in nginx prometheus grafana; do
  ready="$(kubectl get deployment "$app" -n ingress-lab -o jsonpath='{.status.readyReplicas}')"
  [[ "$ready" == 2 ]] || { echo "$app needs 2 ready replicas; found $ready" >&2; exit 1; }
  case "$app" in nginx) path=/ ;; prometheus) path=/-/ready ;; grafana) path=/api/health ;; esac
  code="$(curl --silent --show-error --max-time 20 --output "$LAB_CURL_SINK" --write-out '%{http_code}' -H "Host: $app.lab.test" "$base$path")"
  [[ "$code" == 200 ]] || { echo "$app returned HTTP $code" >&2; exit 1; }
  printf 'PASS %s: 2 ready replicas, ingress HTTP %s\n' "$app" "$code"
done
code="$(curl --silent --show-error --max-time 20 --output "$LAB_CURL_SINK" --write-out '%{http_code}' -H 'Host: missing.lab.test' "$base/")"
[[ "$code" == 404 ]] || { echo "Unknown host returned $code instead of 404" >&2; exit 1; }
echo 'PASS unknown host: HTTP 404'
